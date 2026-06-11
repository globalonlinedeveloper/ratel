#!/usr/bin/env python3
"""Translate the bundled explanations to SIMPLE Tamil (one-time pass,
resumable: fills only missing keys). Usage: BUDGET=35 python3 tool/gen_explanations_ta.py
Needs OPENAI_API_KEY. Writes assets/explanations_ta.json atomically."""
import json, os, time, urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed

KEY = os.environ["OPENAI_API_KEY"]
BUDGET = int(os.environ.get("BUDGET", "35"))
SRC = "assets/explanations.json"
OUT = "assets/explanations_ta.json"

en = json.load(open(SRC))
out = {}
if os.path.exists(OUT):
    try:
        out = json.load(open(OUT))
    except Exception:
        out = {}
miss = [(k, v) for k, v in en.items() if k not in out]
SYS = ("You translate short English-teaching explanations into SIMPLE, "
       "natural Tamil for Tamil-speaking English learners. Keep quoted "
       "English words/sentences IN ENGLISH (they are the learning "
       "material); translate the explanation around them. Plain text.")


def call(item):
    k, v = item
    body = json.dumps({
        "model": "gpt-4o-mini",
        "messages": [{"role": "system", "content": SYS},
                     {"role": "user", "content": v}],
        "max_tokens": 160, "temperature": 0.3,
    }).encode()
    for a in range(3):
        try:
            rq = urllib.request.Request(
                "https://api.openai.com/v1/chat/completions", data=body,
                headers={"Authorization": f"Bearer {KEY}",
                         "Content-Type": "application/json"})
            with urllib.request.urlopen(rq, timeout=30) as r:
                t = json.loads(r.read())["choices"][0]["message"]["content"]
                return k, t.strip()
        except Exception:
            if a == 2:
                return k, None
    return k, None


start = time.time()
done = 0
# NO context manager: its __exit__ waits for every submitted future,
# so a budget break never reached the file write before the outer
# timeout killed us. Write FIRST, then abandon stragglers.
exr = ThreadPoolExecutor(max_workers=24)
futs = [exr.submit(call, it) for it in miss]
for f in as_completed(futs):
    k, v = f.result()
    if v:
        out[k] = v
        done += 1
    if time.time() - start > BUDGET:
        break
tmp = OUT + ".tmp"
json.dump(out, open(tmp, "w"), ensure_ascii=False, indent=0)
os.replace(tmp, OUT)
print(f"total={len(en)} new={done} now={len(out)} "
      f"remaining={len(en) - len(out)}", flush=True)
exr.shutdown(wait=False, cancel_futures=True)
os._exit(0)
