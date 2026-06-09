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
let token=null, phase='load';
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
  if(!token) problems.push('no session token after signup');
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
  if(await page.getByText('+50 XP',{exact:false}).count()<1) problems.push('+50 XP missing');
  phase='persistence';
  await tap(page,'Continue');
  await page.reload({waitUntil:'load'});await page.waitForTimeout(7000);
  await page.mouse.click(420,862);await page.waitForTimeout(1000);
  let persisted=false, pdl=Date.now()+15000;
  while(Date.now()<pdl){ await sem(page); await page.waitForTimeout(600); if(await page.getByText('50',{exact:false}).count()>=1){persisted=true;break;} }
  await page.screenshot({path:'e2e-full.png'});
  if(!persisted) problems.push('XP not persisted after reload (profile not showing 50)');
  // The Sound/Haptics settings live in SwitchListTiles, whose title is merged
  // into one accessible node -> match the aria-label/semantics text, not a
  // standalone text node, and scroll-retry until it renders into the tree.
  const hasSoundToggle=async()=>page.evaluate(()=>{
    const hit=(x)=>(x||'').toLowerCase().includes('sound effects');
    return Array.from(document.querySelectorAll('[aria-label]')).some(e=>hit(e.getAttribute('aria-label')))
      || Array.from(document.querySelectorAll('flt-semantics')).some(e=>hit(e.textContent));
  });
  let soundToggle=false, sdl=Date.now()+9000;
  while(Date.now()<sdl){ await page.mouse.move(240,520); await page.mouse.wheel(0,360); await page.waitForTimeout(550); await sem(page); if(await hasSoundToggle()){soundToggle=true;break;} }
  await page.screenshot({path:'e2e-settings.png'});
  if(!soundToggle) problems.push('Sound settings toggle missing in Profile');
  const hasLabel=async(txt)=>page.evaluate((t)=>{
    const hit=(x)=>(x||'').toLowerCase().includes(t);
    return Array.from(document.querySelectorAll('[aria-label]')).some(e=>hit(e.getAttribute('aria-label')))
      || Array.from(document.querySelectorAll('flt-semantics')).some(e=>hit(e.textContent));
  },txt);
  if(soundToggle && !(await hasLabel('background music'))) problems.push('Background music toggle missing in Profile');
  // AI backend: the 'explain-answer' Edge Function must answer with the LLM
  // (key is server-side only). Uses the throwaway user's JWT.
  phase='ai';
  if(token){
    try{
      const air=await fetch(`${SUPA_URL}/functions/v1/explain-answer`,{method:'POST',headers:{apikey:SUPA_ANON,Authorization:`Bearer ${token}`,'Content-Type':'application/json'},body:JSON.stringify({prompt:'Pick the morning greeting.',userAnswer:'Good night',correctAnswer:'Good morning'})});
      const aj=await air.json().catch(()=>({}));
      if(air.status!==200||typeof aj.explanation!=='string'||!aj.explanation.trim().length) problems.push(`explain-answer fn unhealthy (status ${air.status})`);
      else console.log('explain-answer ok:', aj.explanation.slice(0,60));
    }catch(e){ problems.push('explain-answer fn unreachable: '+e.message); }
  }
}catch(e){problems.push(`crash in ${phase}: ${e.message}`);}
let cleaned=false;
try{ if(token){const r=await fetch(`${SUPA_URL}/rest/v1/rpc/delete_self`,{method:'POST',headers:{apikey:SUPA_ANON,Authorization:`Bearer ${token}`,'Content-Type':'application/json'},body:'{}'});cleaned=(r.status===200||r.status===204);if(!cleaned)console.log('WARN cleanup status',r.status);} }catch(e){console.log('WARN cleanup error',e.message);}
await browser.close(); if(server) server.close();
console.log(`email=${email} token=${token?'yes':'no'} cleaned=${cleaned} consoleErrors=${consoleErrors.length}`);
consoleErrors.slice(0,5).forEach(e=>console.log('  ce:',e.slice(0,140)));
if(problems.length){console.error('E2E FAIL:\n - '+problems.join('\n - '));process.exit(1);}
console.log('E2E PASS: signup -> full lesson -> +50 XP -> persisted -> cleaned up');
