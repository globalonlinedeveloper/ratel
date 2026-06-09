import "jsr:@supabase/functions-js/edge-runtime.d.ts";

// CORS so the Flutter web app can call this from the browser.
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// The OpenAI key is NOT in this source. It is read once, server-side, from the
// RLS-locked public.app_config table using the auto-injected service role, then
// cached in this isolate. It never reaches the repo or the client.
let cachedKey: string | null = null;

async function getOpenAIKey(): Promise<string> {
  if (cachedKey) return cachedKey;
  const url = Deno.env.get("SUPABASE_URL");
  const svc = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !svc) throw new Error("missing service env");
  const r = await fetch(
    `${url}/rest/v1/app_config?key=eq.openai_key&select=val`,
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

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);
  try {
    const { prompt, userAnswer, correctAnswer } = await req.json();
    if (!prompt || !correctAnswer) return json({ error: "missing_fields" }, 400);

    const key = await getOpenAIKey();
    const sys =
      "You are Ratel, a warm, concise English tutor (a fearless honey badger). In 1-2 short sentences (max 40 words), gently explain why the learner's answer is not right and what the correct idea is. Encouraging, plain language, never harsh. Plain text only.";
    const user =
      `Question: ${prompt}\nLearner answered: ${userAnswer ?? "(left blank)"}\nCorrect answer: ${correctAnswer}\nGive the brief explanation.`;

    const ai = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${key}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: sys },
          { role: "user", content: user },
        ],
        max_tokens: 90,
        temperature: 0.5,
      }),
    });
    if (!ai.ok) {
      const t = await ai.text();
      return json({ error: "llm_error", detail: t.slice(0, 160) }, 502);
    }
    const data = await ai.json();
    const explanation = (data.choices?.[0]?.message?.content ?? "").trim() ||
      "Take another look — the correct answer is shown above.";
    return json({ explanation });
  } catch (e) {
    return json({ error: "bad_request", detail: String(e).slice(0, 160) }, 400);
  }
});
