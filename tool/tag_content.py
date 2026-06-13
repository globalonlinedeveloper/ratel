#!/usr/bin/env python3
"""Inc 141 -- DATASET P0 content tagger.

Proposes grammar + concept tags for every LIVE exercise, pinned to the
controlled vocabulary in tool/tag_taxonomy.json, writes a human review sheet,
and (with --seed) PATCHes the tags into content_exercises.

Factory pattern: idempotent (skips already-tagged unless --force), resumable
(LLM proposals cached to disk between runs), BUDGET-capped, secrets from env only.

Env (never printed or committed):
  SUPABASE_URL
  SUPABASE_SERVICE_ROLE_KEY                     # required only for --seed (PATCH)
  SUPABASE_ANON_KEY | SUPABASE_PUBLISHABLE_KEY  # reads (public content)
  OPENAI_API_KEY                                # required unless all needed rows cached
  BUDGET (optional)                             # max LLM chunk-calls this run

Usage:
  python3 tool/tag_content.py --review-out <path>/REVIEW-tags.md   # dry run, no writes
  python3 tool/tag_content.py --seed                               # write tags to DB
"""
import argparse, json, os, re, sys, threading, urllib.request, urllib.error
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
TAXO = os.path.join(HERE, "tag_taxonomy.json")
DEF_URL = os.environ.get("SUPABASE_URL", "https://fkbmodjtxatrqcghhfba.supabase.co").rstrip("/")

def read_key():
    return os.environ.get("SUPABASE_ANON_KEY") or os.environ.get("SUPABASE_PUBLISHABLE_KEY") or ""

def req(url, method="GET", data=None, headers=None):
    r = urllib.request.Request(url, data=data, method=method, headers=headers or {})
    try:
        with urllib.request.urlopen(r, timeout=90) as resp:
            body = resp.read()
            return resp.status, (json.loads(body) if body else None)
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8", "replace")

def load_taxo():
    d = json.load(open(TAXO))
    return d, set(x["key"] for x in d["grammar"]), set(x["key"] for x in d["concept"])

# Keyword -> concept, used only as a guaranteed fallback when the LLM gives no
# valid concept tag (flagged in the review sheet for a human to confirm).
KW = [
  ("greet","greetings"),("describing people","people-describing"),("people","people-describing"),
  ("family","family"),("food","food-drink"),("drink","food-drink"),("routine","daily-routine"),
  ("number","numbers"),("time","time-days"),("day","time-days"),("town","places-town"),
  ("place","places-town"),("shop","shopping"),("weather","weather-seasons"),("season","weather-seasons"),
  ("direction","directions"),("health","health-body"),("body","health-body"),("doctor","health-body"),
  ("job","jobs-work"),("work","jobs-work"),("free time","free-time"),("hobby","free-time"),
  ("travel","travel"),("airport","travel"),("hotel","travel"),("holiday","travel"),
  ("transport","transport"),("getting around","transport"),("home","home"),("house","home"),
  ("feeling","feelings-opinions"),("opinion","feelings-opinions"),("phone","communication"),
  ("email","communication"),("meeting","communication"),("school","school-study"),("study","school-study"),
  ("help","requests-help"),("request","requests-help"),("polite","requests-help"),("suggest","requests-help"),
  ("story","storytelling"),("reason","storytelling"),("agree","agreeing-disagreeing"),
  ("advice","advice"),("wear","clothing"),("cloth","clothing"),("small talk","everyday-phrases"),
  ("phrase","everyday-phrases"),
]
def fallback_concept(lesson_title, unit_subtitle):
    t = (lesson_title + " " + unit_subtitle).lower()
    for kw, c in KW:
        if kw in t:
            return c
    return "everyday-phrases"

def fetch_all(url, key):
    H = {"apikey": key, "Authorization": "Bearer " + key}
    def get(path):
        st, rows = req(url + "/rest/v1/" + path, headers=H)
        if st != 200:
            sys.exit("read failed " + path + ": " + str(st) + " " + str(rows)[:200])
        return rows
    ex = get("content_exercises?select=id,lesson_id,sort_order,type,prompt,sentence,options,"
             "correct_index,correct_order,grammar_tags,concept_tags,state&order=id&limit=2000")
    les = get("content_lessons?select=id,unit_id,title&limit=2000")
    un = get("content_units?select=id,subtitle&limit=2000")
    lt = {l["id"]: l.get("title", "") for l in les}
    lu = {l["id"]: l.get("unit_id", "") for l in les}
    us = {u["id"]: u.get("subtitle", "") for u in un}
    ctx = {e["id"]: (lt.get(e["lesson_id"], ""), us.get(lu.get(e["lesson_id"], ""), "")) for e in ex}
    return ex, ctx

def answer_of(e):
    opts = e.get("options") or []
    ci = e.get("correct_index")
    if isinstance(ci, int) and 0 <= ci < len(opts):
        return str(opts[ci])
    co = e.get("correct_order") or []
    if co:
        return " ".join(str(x) for x in co)
    return ""

def build_prompt(taxo, items):
    gl = "\n".join("- " + x["key"] + ": " + x["desc"] for x in taxo["grammar"])
    cl = "\n".join("- " + x["key"] + ": " + x["desc"] for x in taxo["concept"])
    return (
        "You tag short ESL (English as a second language) exercises for a beginner-to-intermediate course.\n"
        "For EACH exercise choose:\n"
        "  grammar: 1-2 tags naming the language structure or skill it practises\n"
        "  concept: 1-2 tags naming its topic/theme\n"
        "Choose ONLY from the controlled vocabularies below; never invent keys.\n"
        "Prefer the most specific applicable tag. For a single-word vocabulary item, grammar may be\n"
        "'vocabulary' plus a part of speech (nouns/verbs/adjectives/adverbs/pronouns).\n\n"
        "GRAMMAR vocabulary:\n" + gl + "\n\nCONCEPT vocabulary:\n" + cl + "\n\n"
        "Return a strict JSON object mapping each exercise id (a string) to "
        '{"grammar": [...], "concept": [...]}. Include every id exactly once. No commentary.\n\n'
        "Exercises:\n" + json.dumps(items, ensure_ascii=False)
    )

def call_llm(model, prompt):
    key = os.environ.get("OPENAI_API_KEY")
    if not key:
        raise RuntimeError("OPENAI_API_KEY not set")
    body = json.dumps({
        "model": model, "temperature": 0,
        "response_format": {"type": "json_object"},
        "messages": [
            {"role": "system", "content": "You are a precise ESL curriculum tagger. Output strict JSON only."},
            {"role": "user", "content": prompt},
        ],
    }).encode()
    r = urllib.request.Request("https://api.openai.com/v1/chat/completions", data=body,
        headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"}, method="POST")
    with urllib.request.urlopen(r, timeout=90) as resp:
        out = json.loads(resp.read())
    return json.loads(out["choices"][0]["message"]["content"])

def explode(raw_tags, vocab):
    """Keep in-vocab keys; salvage combined keys the LLM sometimes emits
    (e.g. "vocabulary:nouns" or "past-simple, verbs") by splitting on
    separators and keeping any parts that are in the vocabulary."""
    out, bad = [], []
    for t in raw_tags or []:
        if not isinstance(t, str):
            bad.append(str(t)); continue
        t = t.strip()
        if t in vocab:
            out.append(t); continue
        keep = [q for q in re.split(r"[\s:,/|]+", t) if q in vocab]
        if keep: out.extend(keep)
        elif t: bad.append(t)
    return list(dict.fromkeys(out)), sorted(set(bad))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seed", action="store_true", help="PATCH tags into the DB (default: dry run)")
    ap.add_argument("--force", action="store_true", help="re-tag rows that already have tags")
    ap.add_argument("--limit", type=int, default=0, help="cap exercises processed (0=all)")
    ap.add_argument("--chunk", type=int, default=16)
    ap.add_argument("--workers", type=int, default=6)
    ap.add_argument("--model", default="gpt-4o-mini")
    ap.add_argument("--cache", default=os.path.join(HERE, ".tag_cache.json"))
    ap.add_argument("--review-out", default=os.path.join(HERE, "REVIEW-tags.md"))
    args = ap.parse_args()

    taxo, GV, CV = load_taxo()
    rkey = read_key()
    if not rkey:
        sys.exit("no read key (SUPABASE_ANON_KEY / SUPABASE_PUBLISHABLE_KEY)")
    ex, ctx = fetch_all(DEF_URL, rkey)
    ex = [e for e in ex if (e.get("state") or "live") == "live"]

    def needs(e):
        return True if args.force else not (e.get("grammar_tags") and e.get("concept_tags"))
    todo = [e for e in ex if needs(e)]
    if args.limit:
        todo = todo[:args.limit]

    cache = {}
    if os.path.exists(args.cache):
        try: cache = json.load(open(args.cache))
        except Exception: cache = {}
    lock = threading.Lock()

    pending = [e for e in todo if str(e["id"]) not in cache]
    chunks = [pending[i:i+args.chunk] for i in range(0, len(pending), args.chunk)]
    budget = int(os.environ.get("BUDGET", "0")) or len(chunks)
    chunks = chunks[:budget]

    def work(chunk):
        try:
            items = [{
                "id": str(e["id"]), "type": e["type"], "prompt": e.get("prompt") or "",
                "sentence": e.get("sentence") or "", "options": e.get("options") or [],
                "answer": answer_of(e), "lesson": ctx[e["id"]][0], "topic": ctx[e["id"]][1],
            } for e in chunk]
            res = call_llm(args.model, build_prompt(taxo, items))
            with lock:
                for it in items:
                    v = res.get(it["id"]) or {}
                    cache[it["id"]] = {"grammar": v.get("grammar", []), "concept": v.get("concept", [])}
                json.dump(cache, open(args.cache, "w"), ensure_ascii=False)
        except Exception as err:
            with lock:
                print("chunk failed (" + str(len(chunk)) + " items): " + str(err)[:160])

    if chunks:
        with ThreadPoolExecutor(max_workers=args.workers) as pool:
            list(pool.map(work, chunks))

    rows_out = []
    for e in todo:
        prop = cache.get(str(e["id"]), {"grammar": [], "concept": []})
        flags = []
        g, bad_g = explode(prop.get("grammar", []), GV)
        c, bad_c = explode(prop.get("concept", []), CV)
        # Flag a row only when a dimension had NO valid LLM tag and a fallback was
        # used (these are the rows a human should actually look at). Bonus
        # out-of-vocab tokens that the LLM offered alongside a valid tag are noise.
        if not g:
            g = ["vocabulary"]
            flags.append("grammar-fallback" + ((":" + ",".join(bad_g)) if bad_g else ""))
        if not c:
            lt, us = ctx[e["id"]]; c = [fallback_concept(lt, us)]
            flags.append("concept-fallback" + ((":" + ",".join(bad_c)) if bad_c else ""))
        rows_out.append((e, g[:3], c[:3], flags))

    flagged = [r for r in rows_out if r[3]]
    gap = [r for r in rows_out if not r[1] or not r[2]]
    outdir = os.path.dirname(os.path.abspath(args.review_out))
    if outdir: os.makedirs(outdir, exist_ok=True)
    with open(args.review_out, "w") as f:
        f.write("# Inc 141 -- tag review sheet\n\n")
        f.write(str(len(rows_out)) + " exercises proposed | " + str(len(flagged)) +
                " flagged | model " + args.model + "\n\n")
        f.write("Worker reviews per house style: FLAG weirdness, never auto-edit content. "
                "Tags are DB-editable, so corrections are at-leisure, not gating.\n\n")
        f.write("| key | type | prompt / answer | grammar | concept | flags |\n")
        f.write("|---|---|---|---|---|---|\n")
        for e, g, c, flags in rows_out:
            key = str(e["lesson_id"]) + ":" + str(e["sort_order"])
            pr = (e.get("prompt") or "").replace("|", "\\|")
            an = answer_of(e).replace("|", "\\|")
            disp = (pr + ((" -> " + an) if an else ""))[:90]
            f.write("| " + key + " | " + e["type"] + " | " + disp + " | " +
                    " ".join(g) + " | " + " ".join(c) + " | " + " ".join(flags) + " |\n")

    print("todo=" + str(len(todo)) + " proposed=" + str(len(rows_out)) +
          " flagged=" + str(len(flagged)) + " coverage_gap=" + str(len(gap)))
    if gap:
        print("COVERAGE GAP (must be 0):", [str(r[0]["id"]) for r in gap][:10])
    print("review sheet:", args.review_out)

    if args.seed:
        skey = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
        if not skey:
            sys.exit("--seed needs SUPABASE_SERVICE_ROLE_KEY")
        H = {"apikey": skey, "Authorization": "Bearer " + skey,
             "Content-Type": "application/json", "Prefer": "return=minimal"}
        cnt = {"ok": 0}
        slock = threading.Lock()
        def patch(item):
            e, g, c, _flags = item
            body = json.dumps({"grammar_tags": g, "concept_tags": c}).encode()
            st, _ = req(DEF_URL + "/rest/v1/content_exercises?id=eq." + str(e["id"]),
                        method="PATCH", data=body, headers=H)
            with slock:
                if st in (200, 204): cnt["ok"] += 1
                else: print("PATCH " + str(e["id"]) + " -> " + str(st))
        with ThreadPoolExecutor(max_workers=8) as pool:
            list(pool.map(patch, rows_out))
        print("seeded " + str(cnt["ok"]) + "/" + str(len(rows_out)) + " rows")
    else:
        print("dry run (no DB writes) -- pass --seed to write")

if __name__ == "__main__":
    main()
