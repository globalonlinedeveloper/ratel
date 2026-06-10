import base64
import json
import os
import urllib.request
from concurrent.futures import ThreadPoolExecutor

os.chdir('/tmp/rw')
KEY = os.environ['GEMINI_API_KEY']
MODEL = os.environ.get('IMG_MODEL', 'gemini-3-pro-image')
OUT = '/tmp/batch'
os.makedirs(OUT, exist_ok=True)

ACTIONS = {
    'honeyjar': ('ratel-celebrate.webp', [
        "happily holding a golden honey jar with both paws, looking at it with delight",
        "dipping one paw into the honey jar",
        "licking honey off its paw, eyes closed in bliss",
        "big satisfied grin with slightly full cheeks, jar tucked under one arm",
        "hugging the honey jar tight, blissful smile",
        "holding the jar up toward the viewer as if sharing, warm smile",
    ]),
    'snakestare': ('ratel-idle.webp', [
        "arms crossed, calmly staring to the right, totally unbothered",
        "a small green cartoon snake rising up on the right side, the badger eyeing it coolly",
        "intense eye-to-eye stare-down with the small snake, badger leaning in slightly, fearless",
        "the snake leaning back nervously with a sweat drop, the badger unmoved",
        "the snake slinking away small and defeated, the badger giving a slow confident smirk",
        "arms crossed again, calm fearless smile, alone in frame",
    ]),
    'headphones': ('ratel-speak.webp', [
        "wearing big orange headphones, head bobbing to the left, enjoying music",
        "head bobbing to the right, slight smile",
        "eyes closed, vibing, one paw tapping the beat in the air",
        "shoulders doing a small groove, grin",
        "head tilted back a little, mouthing along happily",
        "head bobbing left again, lost in the music",
    ]),
    'gradcap': ('ratel-celebrate.webp', [
        "wearing a black graduation cap, holding a rolled diploma with a ribbon, proud smile",
        "tossing the graduation cap up into the air, looking up",
        "the cap mid-air above it, badger beaming upward, arms half raised",
        "catching the cap with one paw, diploma in the other",
        "placing the cap back on its head at a jaunty angle",
        "raising the diploma high in triumph, huge proud grin",
    ]),
    'partyhat': ('ratel-wave.webp', [
        "wearing a colorful cone party hat, a few confetti specks falling, happy",
        "blowing a paper party horn that extends out, cheeks puffed",
        "the party horn retracting, eyes bright with fun",
        "both arms up in a cheer, confetti specks around",
        "a joyful little hop, party hat slightly tilted",
        "settled, arms up in a happy hold, big smile, confetti drifting",
    ]),
    'wink': ('ratel-speak.webp', [
        "facing the viewer, both eyes open, finger-gun paw starting to rise",
        "one eye winking, paw pointing at the viewer like a finger gun",
        "wink held, big charming grin, paw still pointing",
        "eye reopening, paw lowering a little",
        "both eyes open, playful smile, paw giving a tiny thumbs up",
        "relaxed friendly stance, soft smile",
    ]),
}

PROMPT = (
    "Using the attached character as the EXACT identity reference, generate the SAME "
    "cartoon honey badger mascot: identical colors, proportions, fur shading, line style, "
    "face. Full body, centered, same scale as the reference, occupying the same area of "
    "the frame. Plain solid pure green background (#00FF00), absolutely no shadow, no "
    "outline, no text. Simple props mentioned in the pose (honey jar, snake, headphones, "
    "graduation cap, diploma, party hat, party horn, confetti) are allowed and drawn in "
    "the same cartoon style. This is frame {i} of a 6-frame '{action}' animation loop. "
    "Pose for this frame: {pose}."
)

REFS = {}


def ref64(f):
    if f not in REFS:
        REFS[f] = base64.b64encode(
            open(f'assets/images/{f}', 'rb').read()).decode()
    return REFS[f]


def gen(job):
    action, ref_file, i, pose = job
    path = f'{OUT}/{action}_{i}.png'
    if os.path.exists(path):
        return f'{action}_{i} cached'
    body = {"contents": [{"parts": [
        {"inline_data": {"mime_type": "image/webp", "data": ref64(ref_file)}},
        {"text": PROMPT.format(i=i + 1, action=action, pose=pose)},
    ]}]}
    req = urllib.request.Request(
        f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:generateContent?key={KEY}",
        data=json.dumps(body).encode(),
        headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=100) as r:
            d = json.loads(r.read())
        for part in d['candidates'][0]['content']['parts']:
            if 'inlineData' in part:
                open(path, 'wb').write(
                    base64.b64decode(part['inlineData']['data']))
                return f'{action}_{i} ok'
        return f'{action}_{i} NO-IMAGE'
    except Exception as e:
        return f'{action}_{i} ERR {str(e)[:90]}'


jobs = [(a, rf, i, p) for a, (rf, poses) in ACTIONS.items()
        for i, p in enumerate(poses)]
todo = [j for j in jobs if not os.path.exists(f'{OUT}/{j[0]}_{j[2]}.png')]
limit = int(os.environ.get('LIMIT', '99'))
todo = todo[:limit]
print('todo:', len(todo), 'model:', MODEL, flush=True)
with ThreadPoolExecutor(max_workers=5) as ex:
    for res in ex.map(gen, todo):
        print(res, flush=True)
have = sum(1 for j in jobs if os.path.exists(f'{OUT}/{j[0]}_{j[2]}.png'))
print('frames present:', have, '/', len(jobs), flush=True)
