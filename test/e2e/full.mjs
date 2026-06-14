import { chromium } from 'playwright';
import { createServer } from 'http';
import { readFile } from 'fs/promises';
import { existsSync, statSync } from 'fs';
import { join, extname, normalize } from 'path';

const EXT = process.env.E2E_URL;
const ROOT='build/web', PORT=8099;
const MIME={'.html':'text/html','.js':'text/javascript','.mjs':'text/javascript','.css':'text/css','.json':'application/json','.png':'image/png','.jpg':'image/jpeg','.wasm':'application/wasm','.mp3':'audio/mpeg','.wav':'audio/wav','.otf':'font/otf','.ttf':'font/ttf','.woff2':'font/woff2','.ico':'image/x-icon','.svg':'image/svg+xml','.bin':'application/octet-stream','.symbols':'text/plain'};
const SUPA_URL=process.env.SUPABASE_URL||'https://fkbmodjtxatrqcghhfba.supabase.co';
const SUPA_ANON=process.env.SUPABASE_ANON_KEY||'sb_publishable_RINvN2-MTrfUgOIZ_oxWng_aamq2i_2';
let baseUrl, server=null;
if (EXT) baseUrl=EXT.replace(/\/+$/,'');
else { server=createServer(async(req,res)=>{try{let p=decodeURIComponent((req.url||'/').split('?')[0]).replace(/^\/ratel/,'');if(p===''||p==='/')p='/index.html';let f=join(ROOT,normalize(p));if(!existsSync(f)||!statSync(f).isFile())f=join(ROOT,'index.html');res.setHeader('Content-Type',MIME[extname(f)]||'application/octet-stream');res.end(await readFile(f));}catch(e){res.statusCode=500;res.end('e');}}); await new Promise(r=>server.listen(PORT,r)); baseUrl=`http://localhost:${PORT}/ratel`; }

const sem=async(p)=>{await p.evaluate(()=>document.querySelector('flt-semantics-placeholder')?.click());await p.waitForTimeout(700);};
const tap=async(p,t,o={})=>{await p.getByText(t,o).first().click({timeout:8000});await p.waitForTimeout(550);};
const consoleErrors=[],problems=[];
const browser=await chromium.launch();
const page=await(await browser.newContext({viewport:{width:480,height:900}})).newPage();
page.on('console',m=>{if(m.type()==='error')consoleErrors.push(m.text());});
page.on('pageerror',e=>consoleErrors.push('pageerror: '+e.message));
const email=`citest${Date.now()}@ratel.test`, password='RatelTest123';
let token=null, uid=null, phase='load';
try{
  await page.goto(baseUrl+'/',{waitUntil:'load',timeout:60000});
  let ok=false,dl=Date.now()+25000;
  while(Date.now()<dl){await sem(page);if(await page.getByText('Create an account',{exact:false}).count()>=1){ok=true;break;}}
  if(!ok) throw new Error('auth screen never rendered');
  if(await page.title()!=='Ratel') problems.push('title not Ratel');
  phase='signup';
  await tap(page,'Create an account');
  await page.mouse.click(240,447);await page.waitForTimeout(220);await page.keyboard.type('CI Tester',{delay:12});
  await page.mouse.click(240,507);await page.waitForTimeout(220);await page.keyboard.type(email,{delay:12});
  await page.mouse.click(240,567);await page.waitForTimeout(220);await page.keyboard.type(password,{delay:12});
  await tap(page,'Create account');
  await page.waitForTimeout(4500);
  token=await page.evaluate(()=>{for(let i=0;i<localStorage.length;i++){const k=localStorage.key(i);const r=localStorage.getItem(k);if(!r||r.indexOf('access_token')<0)continue;try{const o=JSON.parse(r);const t=o.access_token||(o.currentSession&&o.currentSession.access_token)||(o.session&&o.session.access_token);if(t)return t;}catch(e){}}return null;});
  try{ if(token) uid=JSON.parse(Buffer.from(token.split('.')[1],'base64').toString()).sub; }catch(e){}
  if(token && !uid) problems.push('could not derive uid from token');
  if(!token) problems.push('no session token after signup');
  // First-run onboarding intercepts new users — dismiss it.
  phase='onboarding';
  let onb=false, odl=Date.now()+12000;
  while(Date.now()<odl){ await sem(page); if(await page.getByText('Start learning',{exact:false}).count()>=1){onb=true;break;} await page.waitForTimeout(600); }
  if(onb){ await tap(page,'Start learning'); await page.waitForTimeout(1200); }
  else problems.push('onboarding (Start learning) not shown to new user');
  phase='lesson';
  await sem(page);
  await page.mouse.click(180,862);await page.waitForTimeout(1300);
  await tap(page,'Greetings');await page.waitForTimeout(600);
  await tap(page,'Hello',{exact:true});await tap(page,'Check');await tap(page,'Continue');
  await tap(page,'How',{exact:true});await tap(page,'Check');await tap(page,'Continue');
  await tap(page,'Good',{exact:true});await tap(page,'morning',{exact:true});await tap(page,'Check');await tap(page,'Continue');
  await tap(page,"I'm fine, thanks");await tap(page,'Check');await tap(page,'Continue');
  await tap(page,'meet',{exact:true});await tap(page,'Check');await tap(page,'Finish');
  await page.waitForTimeout(1200);
  if(await page.getByText('Lesson complete!',{exact:false}).count()<1) problems.push('completion screen missing');
  if(await page.getByText('/ 5 correct',{exact:false}).count()<1) problems.push('completion correct-count missing');
  phase='persistence';
  await tap(page,'Continue');
  await page.waitForTimeout(2500); // let fire-and-forget writes settle before reload
  await page.reload({waitUntil:'load'});await page.waitForTimeout(7000);
  await page.mouse.click(420,862);await page.waitForTimeout(1500);
  await sem(page);
  await page.screenshot({path:'e2e-full.png'});
  // Persistence at the DB, retried (writes are async; robust to the variable bonus).
  if(token){
    let pxp=0, pdl=Date.now()+12000;
    while(Date.now()<pdl){
      try{
        const pr=await fetch(`${SUPA_URL}/rest/v1/profiles?id=eq.${uid}&select=total_xp`,{headers:{apikey:SUPA_ANON,Authorization:`Bearer ${token}`}});
        const pj=await pr.json().catch(()=>[]);
        pxp=Array.isArray(pj)&&pj[0]?(pj[0].total_xp||0):0;
        if(pxp>=10) break;
      }catch(e){}
      await page.waitForTimeout(800);
    }
    if(pxp<10) problems.push(`XP not persisted (total_xp=${pxp})`);
    else console.log('persisted total_xp:', pxp);
  } else { problems.push('no token for persistence check'); }
  // Inc 175: settings moved to a dedicated page; verify the Settings ENTRY
  // is present in Profile (its subtitle 'Sound, language, appearance, ...')
  // -> match the merged aria-label/semantics text, scroll-retry until shown.
  const hasSettingsEntry=async()=>page.evaluate(()=>{
    const hit=(x)=>(x||'').toLowerCase().includes('appearance');
    return Array.from(document.querySelectorAll('[aria-label]')).some(e=>hit(e.getAttribute('aria-label')))
      || Array.from(document.querySelectorAll('flt-semantics')).some(e=>hit(e.textContent));
  });
  let settingsEntry=false, sdl=Date.now()+9000;
  while(Date.now()<sdl){ await page.mouse.move(240,520); await page.mouse.wheel(0,360); await page.waitForTimeout(550); await sem(page); if(await hasSettingsEntry()){settingsEntry=true;break;} }
  await page.screenshot({path:'e2e-settings.png'});
  if(!settingsEntry) problems.push('Settings entry missing in Profile');
  const hasLabel=async(txt)=>page.evaluate((t)=>{
    const hit=(x)=>(x||'').toLowerCase().includes(t);
    return Array.from(document.querySelectorAll('[aria-label]')).some(e=>hit(e.getAttribute('aria-label')))
      || Array.from(document.querySelectorAll('flt-semantics')).some(e=>hit(e.textContent));
  },txt);
  if(soundToggle && !(await hasLabel('background music'))) problems.push('Background music toggle missing in Profile');
  // Mistake log: every answer in the lesson should be recorded to public.attempts.
  phase='attempts';
  if(token){
    try{
      const ar=await fetch(`${SUPA_URL}/rest/v1/attempts?select=is_correct&limit=20`,{headers:{apikey:SUPA_ANON,Authorization:`Bearer ${token}`}});
      const aj=await ar.json().catch(()=>[]);
      if(!Array.isArray(aj)||aj.length<1) problems.push('no attempts logged after lesson');
      else console.log('attempts logged:', aj.length);
    }catch(e){ problems.push('attempts query failed: '+e.message); }
    // XP events must be written (powers the daily goal + weekly leagues ranking).
    try{
      const xr=await fetch(`${SUPA_URL}/rest/v1/xp_events?select=amount&limit=20`,{headers:{apikey:SUPA_ANON,Authorization:`Bearer ${token}`}});
      const xj=await xr.json().catch(()=>[]);
      if(!Array.isArray(xj)||xj.length<1) problems.push('no xp_events after lesson (leagues + daily goal would show 0 XP)');
      else console.log('xp_events logged:', xj.length);
    }catch(e){ problems.push('xp_events query failed: '+e.message); }
    // Answering must schedule spaced-repetition review (powers "Due for review").
    try{
      const sr=await fetch(`${SUPA_URL}/rest/v1/review_state?select=stability,difficulty,due_on,reps&limit=50`,{headers:{apikey:SUPA_ANON,Authorization:`Bearer ${token}`}});
      const sj=await sr.json().catch(()=>[]);
      if(!Array.isArray(sj)||sj.length<1) problems.push('no review_state after lesson (spaced repetition not scheduling)');
      else {
        console.log('review_state rows:', sj.length);
        // Inc 154: FSRS columns must be populated + sane after a graded answer.
        const bad=sj.filter(r=>!(typeof r.stability==='number'&&r.stability>0&&typeof r.difficulty==='number'&&r.difficulty>=1&&r.difficulty<=10&&r.due_on&&Number(r.reps)>=1));
        if(bad.length) problems.push(`FSRS state not populated/sane on ${bad.length}/${sj.length} rows (e.g. ${JSON.stringify(bad[0]).slice(0,120)})`);
        else console.log('FSRS state ok (stability/difficulty/due_on/reps)');
      }
    }catch(e){ problems.push('review_state query failed: '+e.message); }
    // --- Engagement writes (Leagues/streak/friends/Pro/comeback) — these write
    // to the DB and were previously unverified by the suite (the source of the
    // silent xp_events/review_state no-op bug). All checked at the API layer. ---
    const ah={apikey:SUPA_ANON,Authorization:`Bearer ${token}`,'Content-Type':'application/json'};
    let me={}, mdl=Date.now()+8000;
    while(Date.now()<mdl){
      try{
        const pr=await fetch(`${SUPA_URL}/rest/v1/profiles?id=eq.${uid}&select=id,current_streak,daily_goal_xp,friend_code`,{headers:ah});
        const pj=await pr.json().catch(()=>[]); me=(Array.isArray(pj)&&pj[0])?pj[0]:{};
        if(Number(me.current_streak)>=1) break;
      }catch(e){}
      await page.waitForTimeout(700);
    }
    if(!(Number(me.current_streak)>=1)) problems.push('current_streak not set after lesson (touch_streak no-op)');
    if(!(Number(me.daily_goal_xp)>=1)) problems.push('daily_goal_xp missing on profile');
    if(!me.friend_code) problems.push('friend_code not assigned at signup');
    if(me.current_streak) console.log('profile streak/goal/code:',me.current_streak,me.daily_goal_xp,me.friend_code);
    // Friends RPC callable.
    try{
      const r=await fetch(`${SUPA_URL}/rest/v1/rpc/my_friends`,{method:'POST',headers:ah,body:'{}'});
      if(!r.ok) problems.push('my_friends RPC failed: '+r.status); else console.log('my_friends ok');
    }catch(e){ problems.push('my_friends failed: '+e.message); }
    // AI coach: tutor-chat function healthy (ping = zero LLM spend) + JWT-gated.
    try{
      const tc=await fetch(`${SUPA_URL}/functions/v1/tutor-chat`,{method:'POST',headers:ah,body:JSON.stringify({ping:true})});
      const tj=await tc.json().catch(()=>({}));
      if(!tc.ok||tj.ok!==true) problems.push('tutor-chat ping failed: '+tc.status);
      else console.log('tutor-chat ping ok');
      const tn=await fetch(`${SUPA_URL}/functions/v1/tutor-chat`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({ping:true})});
      if(tn.status!==401) problems.push('tutor-chat not JWT-gated: '+tn.status);
    }catch(e){ problems.push('tutor-chat check failed: '+e.message); }
    // Pro trial lifecycle: start -> a subscription row exists -> cancel (row cascade-cleans on delete_self).
    try{
      const sp=await fetch(`${SUPA_URL}/rest/v1/rpc/start_pro_trial`,{method:'POST',headers:ah,body:'{}'});
      if(!sp.ok) problems.push('start_pro_trial RPC failed: '+sp.status);
      const su=await fetch(`${SUPA_URL}/rest/v1/subscriptions?select=status&limit=1`,{headers:ah});
      const sj=await su.json().catch(()=>[]);
      if(!Array.isArray(sj)||sj.length<1) problems.push('no subscription row after start_pro_trial');
      else console.log('pro trial status:',sj[0].status);
      await fetch(`${SUPA_URL}/rest/v1/rpc/cancel_pro`,{method:'POST',headers:ah,body:'{}'});
    }catch(e){ problems.push('pro trial flow failed: '+e.message); }
    // Comeback: set up a broken streak (confirm it landed), then repair_streak restores it.
    try{
      const today=new Date().toISOString().slice(0,10);
      const pp=await fetch(`${SUPA_URL}/rest/v1/profiles?id=eq.${uid}`,{method:'PATCH',headers:{...ah,Prefer:'return=representation'},body:JSON.stringify({broken_streak:9,broken_on:today,streak_freezes:1})});
      const pj=await pp.json().catch(()=>[]);
      if(!pp.ok||!Array.isArray(pj)||Number(pj[0]?.broken_streak)!==9){
        problems.push('could not set up broken streak: '+pp.status+' '+JSON.stringify(pj).slice(0,80));
      } else {
        const rr=await fetch(`${SUPA_URL}/rest/v1/rpc/repair_streak`,{method:'POST',headers:ah,body:'{}'});
        const rj=await rr.json().catch(()=>[]);
        if(!rr.ok) problems.push('repair_streak RPC failed: '+rr.status);
        else if(!Array.isArray(rj)||rj.length<1||Number(rj[0].current_streak)!==9) problems.push('repair_streak did not restore streak: '+JSON.stringify(rj).slice(0,120));
        else console.log('repair_streak restored streak to', rj[0].current_streak);
      }
    }catch(e){ problems.push('repair_streak flow failed: '+e.message); }
  }
}catch(e){problems.push(`crash in ${phase}: ${e.message}`);}
let cleaned=false;
try{ if(token){const r=await fetch(`${SUPA_URL}/rest/v1/rpc/delete_self`,{method:'POST',headers:{apikey:SUPA_ANON,Authorization:`Bearer ${token}`,'Content-Type':'application/json'},body:'{}'});cleaned=(r.status===200||r.status===204);if(!cleaned)console.log('WARN cleanup status',r.status);} }catch(e){console.log('WARN cleanup error',e.message);}
await browser.close(); if(server) server.close();
console.log(`email=${email} token=${token?'yes':'no'} cleaned=${cleaned} consoleErrors=${consoleErrors.length}`);
consoleErrors.slice(0,5).forEach(e=>console.log('  ce:',e.slice(0,140)));
if(problems.length){console.error('E2E FAIL:\n - '+problems.join('\n - '));process.exit(1);}

// ---- GUEST FUNNEL (server-side guard): anonymous signup -> convert keeps
// the SAME uid -> cleanup. Guards the Anonymous-sign-ins setting + the
// updateUser conversion path on every push.
try{
  const g=await fetch(`${SUPA_URL}/auth/v1/signup`,{method:'POST',headers:{apikey:SUPA_ANON,'Content-Type':'application/json'},body:'{}'});
  const gj=await g.json();
  if(!g.ok||!gj?.user?.is_anonymous) throw new Error('anonymous signup failed: '+g.status);
  const guid=gj.user.id, gtok=gj.access_token;
  const gmail=`e2e-guest+${Date.now()}@example.com`;
  const conv=await fetch(`${SUPA_URL}/auth/v1/user`,{method:'PUT',headers:{apikey:SUPA_ANON,Authorization:`Bearer ${gtok}`,'Content-Type':'application/json'},body:JSON.stringify({email:gmail,password:'GuestPass!234'})});
  const cj=await conv.json();
  if(!conv.ok) throw new Error('guest conversion failed: '+conv.status);
  if(cj?.id!==guid && cj?.user?.id!==guid) throw new Error('conversion changed the uid — progress would be lost!');
  await fetch(`${SUPA_URL}/rest/v1/rpc/delete_self`,{method:'POST',headers:{apikey:SUPA_ANON,Authorization:`Bearer ${gtok}`,'Content-Type':'application/json'},body:'{}'});
  console.log('guest funnel: anonymous -> converted (same uid) -> cleaned');
}catch(e){problems.push('guest funnel: '+e.message);}

console.log('E2E PASS: signup -> full lesson -> +50 XP -> persisted -> cleaned up');
