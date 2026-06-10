# Mascot animation pipeline (Tier 3 staged run)

Run from the repo root with GEMINI_API_KEY in env (see the project
tracker playbook for secrets). Requires: python3, numpy, Pillow.

1. `python3 tool/anim/gen_t3.py`  (repeat until `frames present: 36/36`;
   resumable, frames cache in /tmp/batch; default model
   gemini-3.1-flash-image, override with IMG_MODEL env)
2. Edit BOX in `tool/anim/assemble_any.py` if needed — Tier 3 boxes:
   honeyjar 420, snakestare 420, headphones 320, gradcap 420,
   partyhat 420, wink 320 — then run it to build
   `assets/images/ratel-<action>-anim.webp` (atomic writes).
3. REVIEW the contact sheet for off-model frames (drop outliers like
   sleeping did: rebuild with the good 5).
4. `git apply tool/anim/inc57_wiring.patch` — wires: honeyjar (daily
   goal met), snakestare (review drills), headphones (music easter
   egg), gradcap (unit complete + placement pass), partyhat
   (anniversary card), wink into the reaction pool + asset tests.
5. Commit as 'Increment 57 (Tier 3)' and push; CI gates everything.
