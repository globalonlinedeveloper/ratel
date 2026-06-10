import "jsr:@supabase/functions-js/edge-runtime.d.ts";

// Ratel AI tutor — conversation practice with the mascot persona.
// The OpenAI key is NOT in this source: it is read server-side from the
// RLS-locked public.app_config table (service role only) and cached per isolate.
// Rate-limited per user per day via the server-only public.chat_usage table
// (migration 022: bump_chat_usage, service-role-only EXECUTE).

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const FREE_CAP = 20; // messages/day
const PRO_CAP = 200;

let cachedKey: string | null = null;

function env(k: string): string {
  const v = Deno.env.get(k);
  if (!v) throw new Error(`missing env ${k}`);
  return v;
}

async function getOpenAIKey(): Promise<string> {
  if (cachedKey) return cachedKey;
  const svc = env("SUPABASE_SERVICE_ROLE_KEY");
  const r = await fetch(
    `${env("SUPABASE_URL")}/rest/v1/app_config?key=eq.openai_key&select=val`,
    { headers: { apikey: svc, Authorization: `Bearer ${svc}` } },
  );
  if (!r.ok) throw new Error("config fetch failed");
  const rows = await r.json();
  const k = rows?.[0]?.val;
  if (!k) throw new Error("key not configured");
  cachedKey = k;
  return k;
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

// The platform (verify_jwt) has already validated the signature; we only
// need the subject claim to scope the rate limit.
function uidFromAuth(req: Request): string | null {
  try {
    const t = (req.headers.get("authorization") ?? "").replace(
      /^Bearer\s+/i,
      "",
    );
    const p = JSON.parse(
      atob(t.split(".")[1].replace(/-/g, "+").replace(/_/g, "/")),
    );
    return p.sub ?? null;
  } catch {
    return null;
  }
}

const SYSTEM =
  `You are Ratel, a warm, fearless honey badger who coaches English conversation practice.
Rules:
- Reply in simple, clear English (A2-B1 level), 2-3 short sentences, at most 55 words.
- If the learner's last message has an English mistake, first give the corrected sentence, like: Better: "..." — then respond to what they said.
- Always end with one short, friendly question to keep the conversation going.
- Stay on everyday conversation topics. If asked for anything that is not English practice (code, homework answers, other tasks), kindly steer back to practicing English.
- Be encouraging, never harsh. Plain text only, no markdown.`;

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);
  try {
    const body = await req.json().catch(() => ({}));

    // Health check for CI — validates deploy + JWT gate with zero LLM spend.
    if (body.ping === true) return json({ ok: true });

    const uid = uidFromAuth(req);
    if (!uid) return json({ error: "no_user" }, 401);

    // deno-lint-ignore no-explicit-any
    const raw: any[] = Array.isArray(body.messages) ? body.messages : [];
    const msgs = raw
      .filter((m) =>
        m && (m.role === "user" || m.role === "assistant") &&
        typeof m.content === "string" && m.content.trim().length > 0
      )
      .slice(-16)
      .map((m) => ({ role: m.role, content: String(m.content).slice(0, 600) }));
    if (msgs.length === 0 || msgs[msgs.length - 1].role !== "user") {
      return json({ error: "missing_message" }, 400);
    }

    const svc = env("SUPABASE_SERVICE_ROLE_KEY");
    const url = env("SUPABASE_URL");
    const svcH = {
      apikey: svc,
      Authorization: `Bearer ${svc}`,
      "Content-Type": "application/json",
    };

    // Pro users get a higher daily cap.
    const sr = await fetch(
      `${url}/rest/v1/subscriptions?user_id=eq.${uid}&status=in.(trialing,active)&select=status&limit=1`,
      { headers: svcH },
    );
    const pro = sr.ok && ((await sr.json())?.length ?? 0) > 0;
    const cap = pro ? PRO_CAP : FREE_CAP;

    // Atomic daily counter (service-role-only RPC).
    const br = await fetch(`${url}/rest/v1/rpc/bump_chat_usage`, {
      method: "POST",
      headers: svcH,
      body: JSON.stringify({ p_user: uid }),
    });
    if (!br.ok) return json({ error: "usage_error" }, 500);
    const used = Number(await br.text());
    if (used > cap) return json({ error: "daily_limit", used, cap }, 429);

    const ai = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getOpenAIKey()}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [{ role: "system", content: SYSTEM }, ...msgs],
        max_tokens: 220,
        temperature: 0.7,
      }),
    });
    if (!ai.ok) {
      const t = await ai.text();
      return json({ error: "llm_error", detail: t.slice(0, 160) }, 502);
    }
    const data = await ai.json();
    const reply = (data.choices?.[0]?.message?.content ?? "").trim() ||
      "Let's keep practicing! Tell me about your day.";
    return json({ reply, used, cap });
  } catch (e) {
    return json({ error: "bad_request", detail: String(e).slice(0, 160) }, 400);
  }
});
