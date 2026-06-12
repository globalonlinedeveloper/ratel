#!/usr/bin/env python3
"""Inc 140 -- upload the TL-verified catalog cells to Supabase Storage + art_manifest.

Idempotent & resumable: cells already present in art_manifest are skipped
(--force re-uploads everything). Uploads PROCESSED CELLS ONLY from the 17
catalog set folders -- never `*sheet*` archives, never extra-unsorted/ or
_archive-gen/. PNG cells are WebP-converted (quality 80, method 6, alpha
preserved); .webp sources pass through unchanged.

Requires env (service role -- server-side only, NEVER commit or print):
  SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

Usage:
  python3 tool/upload_art.py --root <...>/ratel-assets/anim-frames [--limit N] [--force]
  python3 tool/upload_art.py --root <...> --verify-only
Exit 0 = local == manifest == storage (lockstep); exit 2 = work remaining
(re-run to resume); exit 1 = error/mismatch.
"""
import argparse, io, json, os, sys, urllib.request, urllib.error
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone
from pathlib import Path

SETS = [
    "emotions", "gestures", "scenarios", "checkpoints", "score", "phonics",
    "challenge", "share", "daily", "festivals", "moments", "ui-states",
    "marketing", "extras", "monsoon-cloud", "holi-sprite", "accessories",
]
BUCKET = "art"

def req(url, method="GET", data=None, headers=None, raw=False):
    h = dict(headers or {})
    r = urllib.request.Request(url, data=data, method=method, headers=h)
    with urllib.request.urlopen(r, timeout=30) as resp:
        body = resp.read()
        return resp.status, (body if raw else (json.loads(body) if body else None))

def auth_headers(key, ct=None):
    h = {"apikey": key, "Authorization": f"Bearer {key}"}
    if ct:
        h["Content-Type"] = ct
    return h

def scan_local(root: Path):
    cells = {}
    for s in SETS:
        d = root / s
        if not d.is_dir():
            sys.exit(f"missing set folder: {d}")
        for f in sorted(d.iterdir()):
            if not f.is_file() or "sheet" in f.name.lower():
                continue
            if f.suffix.lower() not in (".png", ".webp"):
                continue
            name = f.stem
            if name in cells:
                sys.exit(f"duplicate cell name across sets: {name} ({cells[name][0]} vs {s})")
            cells[name] = (s, f)
    return cells

def to_webp(src: Path) -> bytes:
    if src.suffix.lower() == ".webp":
        return src.read_bytes()
    from PIL import Image
    im = Image.open(src)
    if im.mode != "RGBA":
        im = im.convert("RGBA")
    buf = io.BytesIO()
    im.save(buf, "WEBP", quality=80, method=6)
    return buf.getvalue()

def fetch_manifest(base, key):
    st, rows = req(f"{base}/rest/v1/art_manifest?select=name,set,path,bytes&limit=2000",
                   headers=auth_headers(key))
    if st != 200:
        sys.exit(f"manifest read failed: {st}")
    return {r["name"]: r for r in rows}

def list_storage(base, key):
    objs = {}
    for s in SETS:
        st, rows = req(f"{base}/storage/v1/object/list/{BUCKET}",
                       method="POST",
                       data=json.dumps({"prefix": s, "limit": 1000, "offset": 0}).encode(),
                       headers=auth_headers(key, "application/json"))
        if st != 200:
            sys.exit(f"storage list failed for {s}: {st}")
        for o in rows:
            if o.get("id"):  # folders come back without id
                objs[f"{s}/{o['name']}"] = (o.get("metadata") or {}).get("size")
    return objs

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True)
    ap.add_argument("--limit", type=int, default=0, help="max uploads this run (resume by re-running)")
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--verify-only", action="store_true")
    a = ap.parse_args()

    base = os.environ.get("SUPABASE_URL", "").rstrip("/")
    key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "")
    if not base or not key:
        sys.exit("env SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY required")

    cells = scan_local(Path(a.root))
    print(f"local cells: {len(cells)}")
    manifest = fetch_manifest(base, key)

    if not a.verify_only:
        todo = [n for n in cells if a.force or n not in manifest]
        if a.limit:
            todo = todo[: a.limit]
        print(f"to upload this run: {len(todo)}")

        def push(name):
            s, src = cells[name]
            data = to_webp(src)
            path = f"{s}/{name}.webp"
            h = auth_headers(key, "image/webp")
            h["x-upsert"] = "true"
            st, _ = req(f"{base}/storage/v1/object/{BUCKET}/{path}", method="POST", data=data, headers=h)
            if st != 200:
                raise RuntimeError(f"upload {path}: {st}")
            return {"name": name, "set": s, "path": path, "bytes": len(data),
                    "updated_at": datetime.now(timezone.utc).isoformat()}

        rows, errs = [], []
        with ThreadPoolExecutor(max_workers=6) as ex:
            for name, fut in [(n, ex.submit(push, n)) for n in todo]:
                try:
                    rows.append(fut.result())
                except Exception as e:  # noqa: BLE001 -- report, keep going
                    errs.append(f"{name}: {e}")
        for i in range(0, len(rows), 100):
            h = auth_headers(key, "application/json")
            h["Prefer"] = "resolution=merge-duplicates,return=minimal"
            st, _ = req(f"{base}/rest/v1/art_manifest", method="POST",
                        data=json.dumps(rows[i:i + 100]).encode(), headers=h)
            if st not in (200, 201, 204):
                sys.exit(f"manifest upsert failed: {st}")
        print(f"uploaded+indexed: {len(rows)}  errors: {len(errs)}")
        for e in errs[:5]:
            print(" ", e)
        manifest = fetch_manifest(base, key)

    storage = list_storage(base, key)
    local_paths = {f"{c[0]}/{n}.webp" for n, c in cells.items()}
    man_paths = {r["path"] for r in manifest.values()}
    print(f"counts -- local: {len(local_paths)}  manifest: {len(man_paths)}  storage: {len(storage)}")
    missing_man = sorted(local_paths - man_paths)[:5]
    orphan_man = sorted(man_paths - local_paths)[:5]
    missing_sto = sorted(man_paths - set(storage))[:5]
    orphan_sto = sorted(set(storage) - man_paths)[:5]
    for label, lst in [("manifest missing", missing_man), ("manifest orphans", orphan_man),
                       ("storage missing", missing_sto), ("storage orphans", orphan_sto)]:
        if lst:
            print(f"  {label}: {lst}")
    if local_paths == man_paths == set(storage):
        print("LOCKSTEP OK")
        sys.exit(0)
    if (local_paths - man_paths) and not a.verify_only:
        print(f"REMAINING {len(local_paths - man_paths)} -- re-run to resume")
        sys.exit(2)
    sys.exit(1)

if __name__ == "__main__":
    main()
