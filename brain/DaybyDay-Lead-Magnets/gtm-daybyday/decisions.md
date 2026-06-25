---
type: decision
status: accepted
date: 2026-06-12
project: DaybyDay-Lead-Magnets
---

## Rebrand in code: "GTM Factory" → "GTM-DaybyDay"

El build actual en `DaybyDay-csv/gtm-dbd` se comercializa y se referencia en código como "GTM Factory" (footer, llms.txt, index.html, LanguageContext, downloadAnalysis, Auth title, pages Seo titles). El nombre del lead magnet y del sub-folder es **GTM-DaybyDay**.

Decisión: rebrand completo en código. Aplicado en este commit: index.html (title + og + twitter + JSON-LD + author), public/llms.txt, LanguageContext (nav.title, auth.title, footer.copyright en es y en), Index.tsx (footer + page title), Auth/Projects/AccountSettings/NotFound (Seo titles), downloadAnalysis.ts (PDF metadata), Auth.tsx (CardTitle). AccountSettings y Projects Seo descriptions también actualizadas para coherencia.

Por qué: la marca "GTM-DaybyDay" es la que se va a posicionar y la que el sub-folder skill referencia. Mantener "GTM Factory" generaba disonancia entre el repo público y la narrativa del producto.

Riesgo conocido: `lovable-tagger` y la URL `gtm-dbd.lovable.app` siguen siendo del entorno Lovable. Pendiente migrar a dominio propio + actualizar referencias si se quiere cortar el cordón.

---

---
type: decision
status: accepted
date: 2026-06-12
project: DaybyDay-Lead-Magnets
---

## Online-presence enrichment wired end-to-end

El product promise de GTM-DaybyDay incluye "rastrear la presencia online" del prospecto. Hasta hoy, phase 1 solo raspaba el website del cliente. Ahora:

- **Nueva edge function `enrich-company`** (`supabase/functions/enrich-company/index.ts`): corre en paralelo CSE de Google, Knowledge Graph y dos pasadas de LLM con search grounding (Gemini 2.5 Flash vía Lovable gateway). Cada provider es best-effort con timeout 8s, nunca bloquea la respuesta. SSRF guard reutilizado.
- **Phase 1 extendida** (`phase-1-market-analysis`): schema Zod acepta `enrichmentContext`. El prompt lo inyecta como bloque "🌐 AUTO-DISCOVERED ONLINE PRESENCE" entre el website scrape y los additional inputs del cliente, con instrucciones de cross-referenciar.
- **Orchestrator** (`useAnalysisOrchestrator.ts`): llama `enrich-company` antes de phase 1, con timeout duro de 8s. Si falla, sigue con phase 1 sin enrichment (degradación elegante). El enrichment se persiste en `phase_outputs.payload._enrichment` y queda en `state.phases.phase1._enrichment` para renderizado futuro.
- **Env vars**: reusa los nombres que ya existían en `.env.example` (`GOOGLE_CUSTOM_SEARCH_ENGINE_ID`, `GOOGLE_CUSTOM_SEARCH_API_KEY`, `GOOGLE_KNOWLEDGE_GRAPH_API_KEY`). No se añadieron secrets nuevos — si los del "Phase 3 audit layer" ya están seteados, enriquecimiento funciona automáticamente.

Decisión: el enrichment corre como pre-step en el cliente (no en la propia phase 1) por dos razones: (1) permite timeouts y degradación sin afectar el contrato de phase 1; (2) deja la opción de cachear el enrichment por (domain, día) en una migración futura sin tocar la función principal.

Por qué: sin enrichment, phase 1 dependía 100% del input del usuario para saber si el cliente tiene LinkedIn, hace ads, sale en prensa, etc. Eso contradice la promesa "pegar una URL y obtener la máxima estrategia". Con enrichment, la LLM de phase 1 cruza 3 fuentes (sitio + KG + web search) en lugar de 1.

---
type: decision
status: accepted
date: 2026-06-12
project: DaybyDay-Lead-Magnets
---

## Detached from Lovable, migrated to new Supabase + static site on Cloudflare

Lovable AI credit ran out and access to the original Supabase project (`sehdzomhwoehmxrnwlsa`) was lost. Decision: full cutover, no going back.

**New infrastructure:**
- **Supabase project:** `llsnjplawndnxbbqzonj` (linked to GitHub, fresh start, no data migration)
- **LLM provider:** MiniMax M3 via Anthropic-compatible API (`https://api.minimax.io/anthropic`), called directly from edge functions. No Cloudflare AI Gateway (the provider config has to be set in the Cloudflare dashboard; deferred). Gemini kept as fallback (currently out of credits).
- **Repo strategy:** old Vite/React SPA thrown out. New repo `DaybyDay-csv/gtm-daybyday-site` (static HTML + one CSS file + ~150 lines of vanilla JS).
- **Hosting:** Cloudflare Pages project `gtm-daybyday`, repo connected, auto-deploys on push to `main`. Custom domain `gtm-daybyday.daybydayconsulting.com` wired via CNAME.
- **The existing `daybydayweb-html` Pages project** (the main `daybydayconsulting.com` site) was NOT touched.

**Backend rewrites:**
- All 8 original edge functions rewritten to use a shared `_shared/llm.ts` helper that calls MiniMax M3 directly (Anthropic Messages API format, with Gemini as fallback).
- 1 new edge function: `orchestrate-analysis` — runs all 7 phases server-side, applies the email gate at phase 5, returns a fully-rendered HTML report. The static site just embeds the HTML; no client-side orchestration.
- 1 new edge function: `create-project` — creates a project row using the service-role key (RLS bypass). The static site calls this instead of doing direct anon insert (which RLS blocks).
- 1 new migration: `20260612000000_static_site_support.sql` adds `industry`, `product_description`, `output_language`, `user_email` to `projects`.
- Migration `20260105000000_phase0_stabilize.sql` had a real ordering bug (used `admin_users` in a policy before creating the table). Patched in the working copy.

**Frontend rewrite (Vite/React → static):**
- 11 files in `gtm-daybyday-site/`: `index.html` (landing), `report.html` (analysis), `privacy.html`, `terms.html`, `llms.txt`, `robots.txt`, `sitemap.xml`, `favicon.svg`, `assets/styles.css`, `assets/app.js`, `_headers`, `_redirects`, `README.md`. Total: zero npm dependencies, no build step.
- Forms post to Edge Functions; report is server-rendered HTML; PDF generation is browser print-to-PDF (no Worker needed).
- Security headers in `_headers` (CSP, HSTS, frame-ancestors, etc.) — the SPA version had none of these.

**Outstanding items:**
- Test the live flow end-to-end at `https://gtm-daybyday.daybydayconsulting.com/` with a real submission
- Tune the orchestrator's report renderer to render richer content from each phase (currently falls back to short output when phase functions return unexpected keys)
- Recharge the Gemini API key (or remove it from secrets) to keep the fallback meaningful
- Consider setting up the Cloudflare AI Gateway provider so we get logging + caching on top of MiniMax
- Rotate all the keys that were shared in chat
