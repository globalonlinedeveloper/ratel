// win-back: lapsed-learner email nudge (daily cron -> pg_net -> here).
// Auth: manual service-role check (verify_jwt off so pg_net can call it).
// Cleanly no-ops until `resend_key` exists in app_config (one-time user step:
// create a Resend API key + verified sender, then schedule the pg_cron job).
// Candidates: winback_candidates() RPC (migration 024) — active before,
// quiet 3-21 days. DEPLOYED ACTIVE (Inc 71); this file tracks the source.
import { createClient } from "npm:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  const auth = req.headers.get("Authorization") ?? "";
  const svc = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  if (auth !== `Bearer ${svc}`) {
    return new Response("forbidden", { status: 403 });
  }

  const supa = createClient(Deno.env.get("SUPABASE_URL")!, svc);
  const { data: cfg } = await supa
    .from("app_config").select("val").eq("key", "resend_key").maybeSingle();
  const key = cfg?.val;
  if (!key) {
    return Response.json({ sent: 0, note: "no resend_key configured" });
  }

  const { data: users, error } = await supa.rpc("winback_candidates");
  if (error) return Response.json({ error: error.message }, { status: 500 });

  let sent = 0;
  for (const u of (users ?? []).slice(0, 100)) {
    const name = u.display_name || "there";
    const r = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${key}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "Ratel <hello@updates.ratel-app.dev>",
        to: u.email,
        subject: u.best_streak > 1
          ? `Your ${u.best_streak}-day streak misses you`
          : "The honey badger kept your spot warm",
        html: `<p>Hi ${name},</p>` +
          `<p>A quick 3-minute lesson is all it takes to get back on track — ` +
          `the honey badger never gives up, and neither should you.</p>` +
          `<p><a href="https://globalonlinedeveloper.github.io/ratel/">` +
          `Jump back in</a></p>`,
      }),
    });
    if (r.ok) sent++;
  }
  return Response.json({ sent });
});
