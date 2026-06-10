import "jsr:@supabase/functions-js/edge-runtime.d.ts";

// Streak-reminder / win-back push sender (FCM HTTP v1).
// SETUP (one-time, by the owner): create a Firebase service-account key
// (Project settings -> Service accounts -> Generate key) and store it:
//   POST {SUPABASE_URL}/rest/v1/app_config  (service role)
//   {"key":"fcm_service_account","val":"<the JSON, stringified>"}
// Until then this function returns 503.
// Invoke (service role only): {"uid":"...","title":"...","body":"..."}

function env(k: string): string {
  const v = Deno.env.get(k);
  if (!v) throw new Error(`missing ${k}`);
  return v;
}

async function gToken(sa: { client_email: string; private_key: string })
    : Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const enc = (o: unknown) =>
    btoa(JSON.stringify(o)).replace(/\+/g, '-').replace(/\//g, '_')
      .replace(/=+$/, '');
  const unsigned = `${enc({ alg: 'RS256', typ: 'JWT' })}.${enc({
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now, exp: now + 3600,
  })}`;
  const pem = sa.private_key.replace(/-----[^-]+-----|\n/g, '');
  const key = await crypto.subtle.importKey('pkcs8',
    Uint8Array.from(atob(pem), (c) => c.charCodeAt(0)),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['sign']);
  const sig = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key,
    new TextEncoder().encode(unsigned));
  const jwt = `${unsigned}.${btoa(String.fromCharCode(
    ...new Uint8Array(sig))).replace(/\+/g, '-').replace(/\//g, '_')
    .replace(/=+$/, '')}`;
  const r = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });
  return (await r.json()).access_token;
}

Deno.serve(async (req: Request) => {
  try {
    const auth = req.headers.get('authorization') ?? '';
    const svc = env('SUPABASE_SERVICE_ROLE_KEY');
    if (!auth.includes(svc)) {
      return new Response('forbidden', { status: 403 });
    }
    const { uid, title, body } = await req.json();
    const url = env('SUPABASE_URL');
    const h = { apikey: svc, Authorization: `Bearer ${svc}` };
    const cfg = await (await fetch(
      `${url}/rest/v1/app_config?key=eq.fcm_service_account&select=val`,
      { headers: h })).json();
    if (!cfg?.[0]?.val) {
      return new Response('fcm service account not configured',
          { status: 503 });
    }
    const sa = JSON.parse(cfg[0].val);
    const prof = await (await fetch(
      `${url}/rest/v1/profiles?id=eq.${uid}&select=fcm_token`,
      { headers: h })).json();
    const token = prof?.[0]?.fcm_token;
    if (!token) return new Response('no token', { status: 404 });
    const access = await gToken(sa);
    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${access}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: { token, notification: { title, body } },
        }),
      });
    return new Response(await res.text(), { status: res.status });
  } catch (e) {
    return new Response(String(e).slice(0, 200), { status: 400 });
  }
});
