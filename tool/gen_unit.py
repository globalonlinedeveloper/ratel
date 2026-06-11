#!/usr/bin/env python3
"""Ratel content factory: DRAFT a unit with an LLM, VALIDATE strictly,
HUMAN-REVIEW the JSON, then SEED it. Never auto-seeds drafts.

  python3 tool/gen_unit.py --draft 11 "Weather & seasons"   # -> drafts/unit_11.json
  python3 tool/gen_unit.py --selftest                        # validator self-test
  python3 tool/gen_unit.py --seed drafts/unit_11.json        # after review

Seeding needs SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY in the env;
drafting needs OPENAI_API_KEY. After seeding: run
  BUDGET=40 python3 tool/gen_explanations.py
and mirror the unit into lib/content.dart (offline fallback), then push.
"""
import json, os, re, sys, urllib.request

TYPES = {"choice", "wordBank", "typed", "listen", "match", "dialogue",
         "multi_blank", "listen_respond", "chat"}


def validate(u):
    """Return a list of problems; empty means the engine can serve it."""
    bad = []
    if not re.fullmatch(r"u\d+", str(u.get("id", ""))):
        bad.append("unit id must look like u11")
    for k in ("title", "subtitle"):
        if not str(u.get(k, "")).strip():
            bad.append(f"unit {k} empty")
    lessons = u.get("lessons", [])
    if not 3 <= len(lessons) <= 6:
        bad.append("3-6 lessons per unit")
    for li, l in enumerate(lessons):
        lid = str(l.get("id", ""))
        if not re.fullmatch(rf"{u.get('id','')}l\d+", lid):
            bad.append(f"lesson {li}: id must look like {u.get('id')}l1")
        if not str(l.get("title", "")).strip():
            bad.append(f"{lid}: title empty")
        exs = l.get("exercises", [])
        if not 4 <= len(exs) <= 7:
            bad.append(f"{lid}: 4-7 exercises")
        for xi, e in enumerate(exs):
            t = e.get("type")
            w = f"{lid}#{xi}"
            if t not in TYPES:
                bad.append(f"{w}: unknown type {t!r}")
                continue
            opts = e.get("options", [])
            cord = e.get("correct_order", [])
            if not str(e.get("prompt", "")).strip():
                bad.append(f"{w}: prompt empty")
            if t == "choice":
                ci = e.get("correct_index")
                if not (isinstance(opts, list) and 2 <= len(opts) <= 5):
                    bad.append(f"{w}: choice needs 2-5 options")
                elif not (isinstance(ci, int) and 0 <= ci < len(opts)):
                    bad.append(f"{w}: correct_index out of range")
                s = e.get("sentence")
                if s is not None and "___" not in s:
                    bad.append(f"{w}: sentence without ___ blank")
            elif t == "wordBank":
                if not (cord and set(cord) <= set(opts)):
                    bad.append(f"{w}: correct_order must use the options")
                if len(opts) < len(cord):
                    bad.append(f"{w}: options must cover the order")
            elif t in ("typed", "listen"):
                if not (isinstance(cord, list) and cord
                        and all(str(a).strip() for a in cord)):
                    bad.append(f"{w}: accepted answers empty")
            elif t == "match":
                if not (2 <= len(opts) <= 5 and len(opts) == len(cord)):
                    bad.append(f"{w}: match needs equal left/right (2-5)")
            elif t == "multi_blank":
                blanks = str(e.get("sentence", "")).count("___")
                if blanks < 1 or len(cord) != blanks:
                    bad.append(f"{w}: answers must match ___ count")
                if not set(cord) <= set(opts):
                    bad.append(f"{w}: answers must come from options")
            elif t == "chat":
                if not str(e.get("sentence", "")).strip():
                    bad.append(f"{w}: chat needs the NPC line")
                if not (isinstance(cord, list) and cord
                        and all(str(a).strip() for a in cord)):
                    bad.append(f"{w}: chat needs accepted replies")
            elif t == "listen_respond":
                ci = e.get("correct_index")
                if not str(e.get("sentence", "")).strip():
                    bad.append(f"{w}: needs the spoken sentence")
                if not (isinstance(opts, list) and 2 <= len(opts) <= 5
                        and isinstance(ci, int)
                        and 0 <= ci < len(opts)):
                    bad.append(f"{w}: bad options/correct_index")
            elif t == "dialogue":
                if not (2 <= len(cord) <= 5 and sorted(opts) == sorted(cord)):
                    bad.append(f"{w}: dialogue lines must equal the order")
    return bad


EXAMPLE = {
    "id": "u99", "title": "Unit 99", "subtitle": "Self test",
    "lessons": [{
        "id": "u99l1", "title": "Test", "exercises": [
            {"type": "choice", "prompt": "Pick", "options": ["a", "b"],
             "correct_index": 0},
            {"type": "wordBank", "prompt": "Build",
             "options": ["I", "go", "home"],
             "correct_order": ["I", "go", "home"]},
            {"type": "match", "prompt": "Match",
             "options": ["hot", "cold"], "correct_order": ["sun", "ice"]},
            {"type": "dialogue", "prompt": "Order",
             "options": ["Hi!", "Hello!"],
             "correct_order": ["Hello!", "Hi!"]},
        ],
    } for _ in range(3)],
}
# fix ids for the example copies
for i, l in enumerate(EXAMPLE["lessons"]):
    EXAMPLE["lessons"][i] = dict(l, id=f"u99l{i+1}")


def selftest():
    assert validate(EXAMPLE) == [], validate(EXAMPLE)
    broken = json.loads(json.dumps(EXAMPLE))
    broken["lessons"][0]["exercises"][0]["correct_index"] = 9
    assert any("out of range" in b for b in validate(broken))
    broken2 = json.loads(json.dumps(EXAMPLE))
    broken2["lessons"][0]["exercises"][1]["correct_order"] = ["nope"]
    assert any("must use the options" in b for b in validate(broken2))
    print("validator selftest OK")


def draft(unit_no, theme):
    key = os.environ["OPENAI_API_KEY"]
    sysmsg = ("You write English-learning content for Ratel (A1-B1). "
              "Output ONLY JSON for one unit: {id:'u%d', title, subtitle, "
              "lessons:[{id:'u%dl1'.., title, exercises:[...]}]}. 5 lessons, "
              "5 exercises each, mixing types: choice {prompt, sentence with "
              "___ optional, options[4], correct_index}, wordBank {prompt, "
              "options, correct_order (uses options)}, typed/listen {prompt, "
              "correct_order=[accepted answers]}, match {prompt, options=left,"
              " correct_order=right, same length}, dialogue {prompt, options="
              "lines, correct_order=the sequence, same strings}. Simple, "
              "warm, practical English." % (unit_no, unit_no))
    body = json.dumps({
        "model": "gpt-4o-mini",
        "messages": [{"role": "system", "content": sysmsg},
                     {"role": "user", "content": f"Theme: {theme}"}],
        "response_format": {"type": "json_object"},
        "max_tokens": 4000, "temperature": 0.6,
    }).encode()
    rq = urllib.request.Request(
        "https://api.openai.com/v1/chat/completions", data=body,
        headers={"Authorization": f"Bearer {key}",
                 "Content-Type": "application/json"})
    with urllib.request.urlopen(rq, timeout=120) as r:
        u = json.loads(json.loads(r.read())["choices"][0]["message"]["content"])
    bad = validate(u)
    os.makedirs("drafts", exist_ok=True)
    out = f"drafts/unit_{unit_no}.json"
    json.dump(u, open(out, "w"), indent=1, ensure_ascii=False)
    print(f"draft -> {out}")
    if bad:
        print("NEEDS FIXES before seeding:")
        for b in bad:
            print(" -", b)
        sys.exit(1)
    print("valid - review the language, then: --seed", out)


def seed(path):
    u = json.load(open(path))
    bad = validate(u)
    if bad:
        print("refusing to seed:", *bad, sep="\n - ")
        sys.exit(1)
    url = os.environ["SUPABASE_URL"]
    svc = os.environ["SUPABASE_SERVICE_ROLE_KEY"]

    def post(table, rows):
        rq = urllib.request.Request(
            f"{url}/rest/v1/{table}", data=json.dumps(rows).encode(),
            headers={"apikey": svc, "Authorization": f"Bearer {svc}",
                     "Content-Type": "application/json",
                     "Prefer": "resolution=merge-duplicates"})
        urllib.request.urlopen(rq, timeout=30).read()

    sort = int(re.sub(r"\D", "", u["id"]))
    post("content_units", [{"id": u["id"], "title": u["title"],
                            "subtitle": u["subtitle"], "sort_order": sort}])
    post("content_lessons", [
        {"id": l["id"], "unit_id": u["id"], "title": l["title"],
         "sort_order": i} for i, l in enumerate(u["lessons"])])
    rows = []
    for l in u["lessons"]:
        for i, e in enumerate(l["exercises"]):
            rows.append({
                "lesson_id": l["id"], "sort_order": i, "type": e["type"],
                "prompt": e["prompt"], "sentence": e.get("sentence"),
                "options": e.get("options", []),
                "correct_index": e.get("correct_index"),
                "correct_order": e.get("correct_order", []),
            })
    post("content_exercises", rows)
    print(f"seeded {u['id']}: {len(u['lessons'])} lessons, {len(rows)} "
          f"exercises.\nNEXT: (1) mirror into lib/content.dart (fallback), "
          f"(2) BUDGET=40 python3 tool/gen_explanations.py, (3) push.")


if __name__ == "__main__":
    a = sys.argv[1:]
    if a[:1] == ["--selftest"]:
        selftest()
    elif a[:1] == ["--draft"] and len(a) >= 3:
        draft(int(a[1]), " ".join(a[2:]))
    elif a[:1] == ["--seed"] and len(a) == 2:
        seed(a[1])
    else:
        print(__doc__)
