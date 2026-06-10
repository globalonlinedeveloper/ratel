import os

import numpy as np
from PIL import Image

os.chdir('/tmp/rw')
SRC = '/tmp/batch'

BOX = {
    'perfect': 420, 'tired': 420, 'flex': 420, 'trophy': 420,
    'dustoff': 420, 'morningstretch': 420, 'medalbite': 420, 'shrugok': 420,
    'listening': 320, 'digging': 320, 'teacher': 320,
    'nod': 320, 'fistpump': 320, 'wink': 320,
}
TIER1 = ['perfect', 'tired', 'listening', 'flex', 'trophy', 'dustoff']
TIER2 = ['morningstretch', 'digging', 'medalbite', 'teacher', 'shrugok',
         'nod', 'fistpump', 'wink']


def key_green(path):
    im = Image.open(path).convert('RGB')
    if im.height > 560:
        im = im.resize((int(im.width * 560 / im.height), 560), Image.LANCZOS)
    a = np.array(im).astype(np.int16)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    mask = (g > 90) & (g > r + 28) & (g > b + 28)
    alpha = np.where(mask, 0, 255).astype(np.uint8)
    spill = (g > np.maximum(r, b) + 8) & ~mask
    a[..., 1] = np.where(spill, np.maximum(r, b) + 8, g)
    return Image.fromarray(
        np.dstack([np.clip(a, 0, 255).astype(np.uint8), alpha]), 'RGBA')


def bleed(im, iters=10):
    a = np.array(im)
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
    return Image.fromarray(a, 'RGBA')


def norm(im, box):
    im = im.crop(im.getbbox())
    scale = (box * 0.88) / im.height
    im = im.resize((max(1, int(im.width * scale)), int(im.height * scale)),
                   Image.LANCZOS)
    cv = Image.new('RGBA', (box, box), (0, 0, 0, 0))
    cv.alpha_composite(im, ((box - im.width) // 2,
                            box - im.height - int(box * 0.02)))
    return cv


def have_all(action):
    return all(os.path.exists(f'{SRC}/{action}_{i}.png') for i in range(6))


for action, box in BOX.items():
    dest = f'assets/images/ratel-{action}-anim.webp'
    if os.path.exists(dest) and os.path.getsize(dest) > 1000:
        print(action, 'cached', os.path.getsize(dest), flush=True)
        continue
    if not have_all(action):
        print(action, 'WAITING for frames', flush=True)
        continue
    frames = [norm(bleed(key_green(f'{SRC}/{action}_{i}.png')), box)
              for i in range(6)]
    tmp = dest + '.tmp'
    frames[0].save(tmp, 'WEBP', save_all=True, append_images=frames[1:],
                   duration=130, loop=0, quality=86, method=6)
    os.replace(tmp, dest)
    print(action, 'built', os.path.getsize(dest), flush=True)


def sheet(actions, out):
    rows = [a for a in actions
            if os.path.exists(f'assets/images/ratel-{a}-anim.webp')]
    if not rows:
        return
    sh = Image.new('RGB', (130 * 6, 140 * len(rows)), (20, 19, 18))
    for r, action in enumerate(rows):
        im = Image.open(f'assets/images/ratel-{action}-anim.webp')
        for i in range(im.n_frames):
            im.seek(i)
            f = im.convert('RGBA').resize((124, 124), Image.LANCZOS)
            sh.paste(f, (130 * i + 3, 140 * r + 8), f)
    sh.save(out)
    print('sheet:', out, flush=True)


sheet(TIER1, '/sessions/modest-cool-brahmagupta/mnt/outputs/tier1_sheet.png')
sheet(TIER2, '/sessions/modest-cool-brahmagupta/mnt/outputs/tier2_sheet.png')
print('done', flush=True)
