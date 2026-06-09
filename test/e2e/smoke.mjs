// Playwright smoke test: serves the freshly-built web app and verifies it boots.
import { chromium } from 'playwright';
import { createServer } from 'http';
import { readFile } from 'fs/promises';
import { existsSync, statSync } from 'fs';
import { join, extname, normalize } from 'path';

const ROOT = 'build/web';
const PORT = 8099;
const MIME = {'.html':'text/html','.js':'text/javascript','.mjs':'text/javascript','.css':'text/css','.json':'application/json','.png':'image/png','.jpg':'image/jpeg','.wasm':'application/wasm','.mp3':'audio/mpeg','.wav':'audio/wav','.otf':'font/otf','.ttf':'font/ttf','.woff2':'font/woff2','.ico':'image/x-icon','.svg':'image/svg+xml','.bin':'application/octet-stream','.symbols':'text/plain'};

const server = createServer(async (req, res) => {
  try {
    let p = decodeURIComponent((req.url || '/').split('?')[0]).replace(/^\/ratel/, '');
    if (p === '' || p === '/') p = '/index.html';
    let file = join(ROOT, normalize(p));
    if (!existsSync(file) || !statSync(file).isFile()) file = join(ROOT, 'index.html');
    res.setHeader('Content-Type', MIME[extname(file)] || 'application/octet-stream');
    res.end(await readFile(file));
  } catch (e) { res.statusCode = 500; res.end('err'); }
});
await new Promise(r => server.listen(PORT, r));

const consoleErrors = [], failed = [];
const browser = await chromium.launch();
const page = await (await browser.newContext({ viewport: { width: 480, height: 900 } })).newPage();
page.on('console', m => { if (m.type() === 'error') consoleErrors.push(m.text()); });
page.on('pageerror', e => consoleErrors.push('pageerror: ' + e.message));
page.on('requestfailed', r => { if (r.url().startsWith(`http://localhost:${PORT}`)) failed.push(r.url() + ' :: ' + (r.failure()?.errorText || '')); });

let title = '', login = 0, create = 0;
try {
  await page.goto(`http://localhost:${PORT}/ratel/`, { waitUntil: 'load', timeout: 60000 });
  const deadline = Date.now() + 30000;
  while (Date.now() < deadline) {
    await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
    await page.waitForTimeout(1500);
    login = await page.getByText('Log in', { exact: false }).count();
    create = await page.getByText('Create an account', { exact: false }).count();
    if (login >= 1 && create >= 1) break;
  }
  title = await page.title();
  await page.screenshot({ path: 'e2e-smoke.png' });
} catch (e) { console.error('run error:', e.message); }
await browser.close(); server.close();

console.log(`title="${title}" loginText=${login} createText=${create} localAssetFails=${failed.length} consoleErrors=${consoleErrors.length}`);
failed.slice(0, 6).forEach(f => console.log('  asset-fail:', f));
consoleErrors.slice(0, 8).forEach(e => console.log('  console-error:', e.slice(0, 160)));
const fail = [];
if (title !== 'Ratel') fail.push(`title is "${title}"`);
if (login < 1 || create < 1) fail.push(`auth screen not detected (login=${login} create=${create})`);
if (failed.length) fail.push(`${failed.length} local asset failures`);
if (fail.length) { console.error('SMOKE FAIL: ' + fail.join('; ')); process.exit(1); }
console.log('SMOKE PASS - app booted, auth screen rendered, all local assets served.');
