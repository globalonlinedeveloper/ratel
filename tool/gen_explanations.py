import re, json, os
src=open('lib/content.dart').read()
OUT='assets/explanations.json'

def strings_in(seg):
    res=[];i=0
    while i<len(seg):
        c=seg[i]
        if c in "\"'":
            q=c;i+=1;buf=''
            while i<len(seg):
                if seg[i]=='\\':buf+=seg[i+1];i+=2;continue
                if seg[i]==q:break
                buf+=seg[i];i+=1
            res.append(buf);i+=1
        else:i+=1
    return res
def match_paren(s,i):
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
def list_after(b,l):
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
def str_after(b,l):
    m=re.search(l+r"\s*:\s*",b)
    if not m:return None
    r=b[m.end():];j=0
    while j<len(r) and r[j] not in "\"'":
        if r[j] in ',)':return None
        j+=1
    s=strings_in(r[j:]);return s[0] if s else None

lpos=[(m.group(1),m.start()) for m in re.finditer(r"Lesson\(\s*id:\s*'([^']+)'",src)]
lpos.append((None,len(src)))
EX=[]
for k in range(len(lpos)-1):
    lid,st=lpos[k];en=lpos[k+1][1];seg=src[st:en];xi=0
    for em in re.finditer(r"Exercise\.(choice|wordBank)\(",seg):
        et=em.group(1);op=seg.index('(',em.start());cp=match_paren(seg,op);b=seg[op+1:cp]
        ci=re.search(r"correctIndex:\s*(-?\d+)",b)
        EX.append(dict(lid=lid,exidx=xi,type=et,prompt=str_after(b,'prompt'),sentence=str_after(b,'sentence'),
            options=list_after(b,'options'),correctIndex=int(ci.group(1)) if ci else None,correctOrder=list_after(b,'correctOrder')))
        xi+=1

BE={'am','is','are','was','were'}
def be_hint(sentence,correct):
    if not sentence or '___' not in sentence or correct not in BE: return ''
    pre=sentence.split('___')[0].strip()
    w=re.findall(r"[A-Za-z']+",pre)
    subj=w[-1] if w else ''
    sl=subj.lower()
    if correct=='am': return ' Use "am" with "I".'
    if correct=='are': return f' Use "are" with "{subj}".' if subj else ' Use "are" with you/we/they or plural subjects.'
    if correct=='is': return f' Use "is" with a singular subject like "{subj}".' if subj else ' Use "is" with he/she/it or a singular subject.'
    if correct=='was': return ' Use "was" with I/he/she/it (past, singular).'
    if correct=='were': return ' Use "were" with you/we/they (past, plural).'
    return ''

def cap(s): return s[:1].upper()+s[1:] if s else s

def choice_expl(e,j):
    ci=e['correctIndex'];correct=e['options'][ci];wrong=e['options'][j];prompt=e['prompt'];sent=e['sentence']
    # 1) fill-in-the-blank with a sentence -> show the completed sentence (+ grammar hint)
    blank = sent if sent else (prompt if '___' in prompt else None)
    if blank and '___' in blank:
        filled=blank.replace('___',correct)
        return f'"{cap(filled.strip())}" is correct, so "{wrong}" does not fit here.{be_hint(blank,correct)}'
    # 2) category questions: "Which word is a greeting?" / "Which word means X?"
    m=re.match(r"^Which (?:word |one )?(is|means) (an? )?(.+?)\?*$",prompt,re.I)
    if m:
        verb=m.group(1).lower(); art=(m.group(2) or '').strip(); noun=m.group(3).strip()
        if verb=='means':
            return f'"{correct}" means {noun}, but "{wrong}" does not — that is why "{correct}" is the answer.'
        cat=(art+' ' if art else '')+noun
        return f'"{correct}" is {cat}, but "{wrong}" is not — that is why "{correct}" is the answer.'
    # 3) clean generic (no prompt embedding -> no quote clashes)
    return f'"{correct}" is the correct answer here, so "{wrong}" does not fit.'

def wb_expl(e):
    correct=' '.join(e['correctOrder'])
    return f'The correct order is "{correct}". Arrange the words this way to make a natural English sentence.'

out={}
for e in EX:
    if e['type']=='choice':
        for j in range(len(e['options'])):
            if j==e['correctIndex']:continue
            out[f"{e['lid']}:{e['exidx']}:{j}"]=choice_expl(e,j)
    else:
        out[f"{e['lid']}:{e['exidx']}:wb"]=wb_expl(e)

json.dump(out,open(OUT,'w'),ensure_ascii=False,indent=0,sort_keys=True)
print("keys:",len(out)," bytes:",os.path.getsize(OUT))
print("--- samples across types ---")
for k in ['u1l1:0:1','u1l1:0:2','u1l1:2:wb','u1l1:3:1','u1l2:1:1','u1l2:1:2','u1l2:3:1']:
    print(k,'->',out.get(k))
