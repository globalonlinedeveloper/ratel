"""Inc 122 full rebuild: all 23 loops + the never-assembled jump, v2
pipeline (badger-anchored registration, shared scale, satellites kept,
text rejected), user-picked pacing = current x1.5."""
import os
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

SHEETS = '/sessions/modest-cool-brahmagupta/mnt/Apps/ratel-assets/anim-frames/6 Frames'
OUT = '/tmp/rw/assets/images'
QA = '/tmp/qa'

# action -> (sheet, new duration = audited x1.5, pingpong)
PLAN = {
    'jump': ('L1 jump (lesson complete).png', 242, False),
    'perfect': ('L2 perfect (55 lesson).png', 242, False),
    'karate': ('L3 karate (hot combo).png', 281, False),
    'listening': ('L4 listening (listen exercises).png', 332, True),
    'crying': ('L5 crying (streak broken).png', 357, True),
    'dustoff': ('L6 dustoff (streak repaired).png', 306, False),
    'flex': ('L7 flex (streak milestone).png', 306, False),
    'trophy': ('L8 trophy (league promotion).png', 281, False),
    'thumbsup': ('L9 thumbsup (quests done).png', 281, False),
    'sleeping': ('L10 sleeping (streak at risk).png', 390, True),
    'morningstretch':
        ('L11 morningstretch (first open of the day).png', 332, False),
    'medalbite': ('L12 medalbite (new achievement).png', 306, False),
    'tired': ('L13 tired (hearts empty).png', 383, True),
    'shrugok': ('L14 shrugok (2+ misses, kind coach).png', 357, True),
    'digging': ('L15 digging (loadingempty — the brand move).png', 255, False),
    'honeyjar': ('L16 honeyjar (daily goal met).png', 306, False),
    'snakestare': ('L17 snakestare (mistake-review drill).png', 357, False),
    'headphones': ('L18 headphones (music easter egg).png', 306, False),
    'gradcap': ('L19 gradcap (unit complete  placement).png', 281, False),
    'partyhat': ('L20 partyhat (anniversaryseasonal).png', 281, False),
    'teacher': ('Teacher loop.png', 357, True),
}
TRIPLE = ('L21 nod · L22 fistpump · L23 wink (correct-answer pool, micro).png',
          [('nod', 281, True), ('fistpump', 255, False), ('wink', 281, False)])
BOX = {'listening': 320, 'digging': 320, 'teacher': 320,
       'nod': 320, 'fistpump': 320, 'wink': 320}


def key_green(path):
    im = Image.open(path).convert('RGB')
    a = np.array(im).astype(np.int16)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    mask = (g > 90) & (g > r + 28) & (g > b + 28)
    alpha = np.where(mask, 0, 255).astype(np.uint8)
    spill = (g > np.maximum(r, b) + 8) & ~mask
    a[..., 1] = np.where(spill, np.maximum(r, b) + 8, g)
    return np.dstack([np.clip(a, 0, 255).astype(np.uint8), alpha])


def bleed(a, iters=6):
    rgb = a[..., :3].astype(np.float32)
    known = a[..., 3] > 0
    for _ in range(iters):
        if known.all():
            break
        acc = np.zeros_like(rgb)
        cnt = np.zeros(known.shape, np.float32)
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                if dx == 0 and dy == 0:
                    continue
                sk = np.roll(known, (dy, dx), (0, 1))
                sr = np.roll(rgb, (dy, dx), (0, 1))
                m = sk & ~known
                acc[m] += sr[m]
                cnt[m] += 1
        newly = (cnt > 0) & ~known
        if not newly.any():
            break
        rgb[newly] = acc[newly] / cnt[newly, None]
        known |= newly
    a[..., :3] = np.clip(rgb, 0, 255).astype(np.uint8)
    return a


def groups_from_sheet(path, expect, drop_text=False):
    """Anchor blobs (badgers) found by size; satellites join the nearest
    badger; text (small + dark-neutral) optionally dropped. Returns
    reading-order list of (rgba_crop, (anchor_x, anchor_bottom_y))."""
    a = bleed(key_green(path))
    h, w = a.shape[:2]
    lab, n = ndimage.label(a[..., 3] > 0, structure=np.ones((3, 3)))
    blobs = []
    for i in range(1, n + 1):
        ys, xs = np.where(lab == i)
        if ys.size < 150:
            continue
        if drop_text and ys.size < 2500:
            mean = a[ys, xs, :3].mean(0)
            if mean.max() < 100:
                continue
        blobs.append({'i': i, 'a': ys.size, 'ys': ys, 'xs': xs,
                      'cy': ys.mean(), 'cx': xs.mean()})
    amax = max(b['a'] for b in blobs)
    anchors = [b for b in blobs if b['a'] >= amax * 0.25]
    sats = [b for b in blobs if b['a'] < amax * 0.25]
    assert len(anchors) == expect, f'{path}: {len(anchors)} anchors'
    for s in sats:
        near = min(anchors, key=lambda b: (b['cy'] - s['cy']) ** 2 +
                   (b['cx'] - s['cx']) ** 2)
        near.setdefault('kids', []).append(s)
    # reading order: band rows by cy, then cx
    anchors.sort(key=lambda b: b['cy'])
    rows, cur = [], [anchors[0]]
    for b in anchors[1:]:
        if b['cy'] - cur[-1]['cy'] > h * 0.12:
            rows.append(cur)
            cur = [b]
        else:
            cur.append(b)
    rows.append(cur)
    ordered = [b for row in rows for b in sorted(row, key=lambda x: x['cx'])]
    out = []
    for b in ordered:
        members = [b] + b.get('kids', [])
        keep = np.zeros((h, w), bool)
        for m in members:
            keep[m['ys'], m['xs']] = True
        y0 = min(m['ys'].min() for m in members)
        y1 = max(m['ys'].max() for m in members)
        x0 = min(m['xs'].min() for m in members)
        x1 = max(m['xs'].max() for m in members)
        crop = a[y0:y1 + 1, x0:x1 + 1].copy()
        crop[..., 3] = np.where(keep[y0:y1 + 1, x0:x1 + 1], crop[..., 3], 0)
        out.append((crop, (b['cx'] - x0, b['ys'].max() - y0)))
    return out


def assemble(frames, box, dur, pingpong, dest):
    # scale from the REGISTERED union spread (anchor-relative extents),
    # so no frame can clip regardless of where satellites sit
    rl = max(ax for f, (ax, ay) in frames)
    rr = max(f.shape[1] - ax for f, (ax, ay) in frames)
    ru = max(ay for f, (ax, ay) in frames)
    rd = max(f.shape[0] - ay for f, (ax, ay) in frames)
    s = min(box * 0.96 / (rl + rr), box * 0.94 / (ru + rd))
    cx = (box - (rl + rr) * s) / 2 + rl * s
    cy = (box - 2) - rd * s
    cvs = []
    for f, (ax, ay) in frames:
        im = Image.fromarray(f, 'RGBA')
        im = im.resize((max(1, int(im.width * s)),
                        max(1, int(im.height * s))), Image.LANCZOS)
        cv = Image.new('RGBA', (box, box), (0, 0, 0, 0))
        cv.alpha_composite(im, (int(cx - ax * s), int(cy - ay * s)))
        cvs.append(cv)
    seq = cvs + cvs[-2:0:-1] if pingpong else cvs
    seq[0].save(dest, 'WEBP', save_all=True, append_images=seq[1:],
                duration=dur, loop=0, quality=86, method=4)


def strip(name, frames):
    cs = Image.new('RGBA', (6 * 130 + 90, 140), (120, 120, 120, 255))
    from PIL import ImageDraw
    ImageDraw.Draw(cs).text((6, 60), name[:10], fill=(255, 255, 0))
    for k, (f, _) in enumerate(frames[:6]):
        t = Image.fromarray(f, 'RGBA')
        t.thumbnail((124, 124))
        cs.alpha_composite(t, (88 + k * 130, 8))
    return cs


def run(which):
    os.makedirs(QA, exist_ok=True)
    strips = []
    if which in ('1', 'all'):
        items = [x for x in list(PLAN.items())[:11]]
    else:
        items = [x for x in list(PLAN.items())[11:]]
    for action, (sheet, dur, pp) in items:
        fr = groups_from_sheet(f'{SHEETS}/{sheet}', 6)
        assemble(fr, BOX.get(action, 420), dur, pp,
                 f'{OUT}/ratel-{action}-anim.webp')
        strips.append(strip(action, fr))
        print(action, 'ok', flush=True)
    if which == '2':  # triple rides with batch 2
        fr18 = groups_from_sheet(f'{SHEETS}/{TRIPLE[0]}', 18, drop_text=True)
        for row, (action, dur, pp) in enumerate(TRIPLE[1]):
            fr = fr18[row * 6:(row + 1) * 6]
            assemble(fr, BOX.get(action, 420), dur, pp,
                     f'{OUT}/ratel-{action}-anim.webp')
            strips.append(strip(action, fr))
            print(action, 'ok', flush=True)
    mosaic = Image.new('RGBA', (strips[0].width, 140 * len(strips)),
                       (120, 120, 120, 255))
    for k, s in enumerate(strips):
        mosaic.alpha_composite(s, (0, k * 140))
    mosaic.convert('RGB').save(f'{QA}/qa_batch{which}.png')
    print('batch', which, 'done')


if __name__ == '__main__':
    run(sys.argv[1])
                                                                                                                                      