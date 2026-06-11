# One-time authoring tool: generate realistic, teaching explanations for every
# fixed wrong-answer, using the LLM ONCE. Output is bundled at
# assets/explanations.json and served locally -> ZERO runtime/API cost.
# Resumable: re-run to fill only missing keys. Needs OPENAI_API_KEY in env.
import re, json, os, time, urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
src=open('lib/content.dart').read(); KEY=os.environ['OPENAI_API_KEY']
OUT='assets/explanations.json'; BUDGET=float(os.environ.get('BUDGET','38'))
def strings_in(seg):
    r=[];i=0
    while i<len(seg):
        c=seg[i]
        if c in "\"'":
            q=c;i+=1;b=''
            while i<len(seg):
                if seg[i]=='\\':b+=seg[i+1];i+=2;continue
                if seg[i]==q:break
                b+=seg[i];i+=1
            r.append(b);i+=1
        else:i+=1
    return r
def mp(s,i):
    d=0
    while i<len(s):
        c=s[i]
        if c in "\"'":
            q=c;i+=1
            while i<len(s):
                if s[i]=='\\':i+=2;continue
                if s[i]==q:break
                i+=1
        elif c=='(':d+=1
        elif c==')':
            d-=1
            if d==0:return i
        i+=1
    return -1
def la(b,l):
    m=re.search(l+r"\s*:\s*\[",b)
    if not m:return []
    lb=b.index('[',m.start());d=0;i=lb
    while i<len(b):
        c=b[i]
        if c in "\"'":
            q=c;i+=1
            while i<len(b):
                if b[i]=='\\':i+=2;continue
                if b[i]==q:break
                i+=1
        elif c=='[':d+=1
        elif c==']':
            d-=1
            if d==0:break
        i+=1
    return strings_in(b[lb:i+1])
def sa(b,l):
    m=re.search(l+r"\s*:\s*",b)
    if not m:return None
    r=b[m.end():];j=0
    while j<len(r) and r[j] not in "\"'":
        if r[j] in ',)':return None
        j+=1
    s=strings_in(r[j:]);return s[0] if s else None
lp=[(m.group(1),m.start()) for m in re.finditer(r"Lesson\(\s*id:\s*'([^']+)'",src)];lp.append((None,len(src)))
EX=[]
for k in range(len(lp)-1):
    lid,st=lp[k];en=lp[k+1][1];sg=src[st:en];xi=0
    for em in re.finditer(r"Exercise\.(choice|wordBank|typed|listen|matchPairs|dialogueOrder|multiBlank|listenRespond)\(",sg):
        et=em.group(1);op=sg.index('(',em.start());cp=mp(sg,op);b=sg[op+1:cp]
        ci=re.search(r"correctIndex:\s*(-?\d+)",b)
        EX.append(dict(lid=lid,exidx=xi,type=et,prompt=sa(b,'prompt'),sentence=sa(b,'sentence'),
            options=la(b,'options') or la(b,'lines') or la(b,'left'),
            correctIndex=int(ci.group(1)) if ci else None,
            correctOrder=la(b,'correctOrder'),accepted=la(b,'accepted')));xi+=1
def la_lines(e):
    return e['correctOrder'] or e['options'] or []
tasks=[]
for e in EX:
    if e['type']=='choice':
        ci=e['correctIndex'];cor=e['options'][ci]
        for j,opt in enumerate(e['options']):
            if j==ci:continue
            ctx=f"Question: {e['prompt']}"+(f"\nSentence: {e['sentence']}" if e['sentence'] else "")
            u=(f"{ctx}\nThe learner chose: \"{opt}\"\nThe correct answer is: \"{cor}\"\n"
               f"In 1-2 short sentences (max 35 words), teach WHY \"{cor}\" is right AND what \"{opt}\" actually is or why it does not fit here. "
               f"Give a real, learnable reason (meaning, category, or grammar rule) — never just restate that one is correct and the other is not.")
            tasks.append((f"{e['lid']}:{e['exidx']}:{j}",u))
    elif e['type']=='wordBank':
        cor=' '.join(e['correctOrder'])
        u=(f"Task: arrange words into a correct English sentence.\nThe correct sentence is: \"{cor}\"\n"
           f"In 1-2 short sentences (max 35 words), teach WHY the words go in this order (subject-verb-object, adjective before noun, etc.). "
           f"Give a real grammar reason a learner can reuse — not just 'arrange it this way'.")
        tasks.append((f"{e['lid']}:{e['exidx']}:wb",u))
    elif e['type']=='matchPairs':
        pass  # match boards never show a wrong banner -> no key
    elif e['type']=='multiBlank':
        cor=', '.join(e['correctOrder'] or [])
        u=(f"Task: fill the blanks in '{e.get('sentence') or ''}' in order.\nThe answers are: \"{cor}\"\n"
           f"In 1-2 short sentences (max 35 words), teach WHY these words fit these blanks (meaning or grammar) so a learner can reuse the rule.")
        tasks.append((f"{e['lid']}:{e['exidx']}:mb",u))
    elif e['type']=='listenRespond':
        ci=e['correctIndex'];cor=e['options'][ci]
        for j,opt in enumerate(e['options']):
            if j==ci:continue
            u=(f"The learner HEARD: \"{e.get('sentence') or ''}\" and had to pick the best reply.\n"
               f"They chose \"{opt}\"; the right reply is \"{cor}\".\n"
               f"In 1-2 short sentences (max 35 words), teach WHY \"{cor}\" answers what was heard and what \"{opt}\" would answer instead.")
            tasks.append((f"{e['lid']}:{e['exidx']}:{j}",u))
    elif e['type']=='dialogueOrder':
        cor='  /  '.join(la_lines(e))
        u=(f"Task: put the lines of a short English conversation in order.\nThe correct order is: \"{cor}\"\n"
           f"In 1-2 short sentences (max 35 words), teach WHY this order makes sense (question before answer, greeting first, reaction last). "
           f"Give a reusable conversation-logic reason, not just 'this is the order'.")
        tasks.append((f"{e['lid']}:{e['exidx']}:do",u))
    else:
        cor=(e['accepted'] or e['correctOrder'])[0]
        ctx=f"Question: {e['prompt']}"+(f"\nSentence: {e['sentence']}" if e['sentence'] else "")
        u=(f"{ctx}\nThe learner must TYPE the answer. The correct answer is: \"{cor}\"\n"
           f"In 1-2 short sentences (max 35 words), teach what \"{cor}\" means and WHY it fits here "
           f"(meaning, category, or grammar rule) so a learner can remember it. Plain text.")
        tasks.append((f"{e['lid']}:{e['exidx']}:ty",u))
out={}
if os.path.exists(OUT):
    try:out=json.load(open(OUT))
    except:out={}
miss=[t for t in tasks if t[0] not in out]
SYS="You are Ratel, a warm, encouraging English tutor (a fearless honey badger). Plain text only, no markdown. Be specific and teach the reason."
def call(t):
    key,u=t
    body=json.dumps({"model":"gpt-4o-mini","messages":[{"role":"system","content":SYS},{"role":"user","content":u}],"max_tokens":80,"temperature":0.5}).encode()
    for a in range(3):
        try:
            rq=urllib.request.Request("https://api.openai.com/v1/chat/completions",data=body,headers={"Authorization":f"Bearer {KEY}","Content-Type":"application/json"})
            with urllib.request.urlopen(rq,timeout=30) as r:return key,json.loads(r.read())["choices"][0]["message"]["content"].strip()
        except Exception:
            if a==2:return key,None
    return key,None
start=time.time();done=0
with ThreadPoolExecutor(max_workers=24) as exr:
    futs=[exr.submit(call,t) for t in miss]
    for f in as_completed(futs):
        k,v=f.result()
        if v:out[k]=v;done+=1
        if time.time()-start>BUDGET:break
json.dump(out,open(OUT,'w'),ensure_ascii=False,indent=0,sort_keys=True)
print(f"total={len(tasks)} new={done} now={len(out)} remaining={len(tasks)-len(out)} bytes={os.path.getsize(OUT)}")
