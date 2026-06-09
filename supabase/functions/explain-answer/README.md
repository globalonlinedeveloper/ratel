# explain-answer (Supabase Edge Function)

Server-side LLM tutor for Ratel. The Flutter client invokes it (with the user's
session JWT) after a wrong answer; it returns a short, friendly explanation.

**Security:** the OpenAI key is NOT in this repo. It lives in the RLS-locked
`public.app_config` table (migration `004_app_config_server_only`), readable only
by the service role. This function reads it server-side and caches it per isolate.
`verify_jwt` is on, so only authenticated callers reach it.

Deploy: via the Supabase MCP `deploy_edge_function` (project `fkbmodjtxatrqcghhfba`),
or `supabase functions deploy explain-answer`. To set/rotate the key (service role):
`POST {SUPABASE_URL}/rest/v1/app_config` with `{"key":"openai_key","val":"<KEY>"}`
and header `Prefer: resolution=merge-duplicates`.
