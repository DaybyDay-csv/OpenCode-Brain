# gtm-daybyday

> Sub-folder de DaybyDay-Lead-Magnets dedicado al lead magnet GTM-DaybyDay.

**Estado actual (2026-06-12):** cortado de Lovable. Backend en Supabase `llsnjplawndnxbbqzonj` (nuevo, sin migración de datos). Frontend reescrito a HTML estático en `DaybyDay-csv/gtm-daybyday-site`. Desplegado en Cloudflare Pages en `https://gtm-daybyday.daybydayconsulting.com`.

## Estado actual

GTM-DaybyDay es un sistema en desarrollo que, a partir de pegar la URL de un negocio, analiza en primera instancia el sitio, rastrea su presencia online, y desglosa su core offer, buyer persona y messaging para proponer una go to market strategy completa con el máximo valor estratégico para el usuario. El input es mínimo (una URL) y el output es un plan GTM accionable.

**Build actual** — repo `DaybyDay-csv/gtm-dbd` (Lovable-generated Vite + React + TS + shadcn/ui + Tailwind). Frontend SPA con Supabase como backend. La marca en código es **"GTM Factory"** (no "GTM-DaybyDay"). Llms.txt posiciona el producto como "AI-powered go-to-market intelligence" para B2B y B2C.

### Stack

- **Frontend:** Vite + React 18 + TypeScript, shadcn/ui (Radix), Tailwind, react-router, react-query, html2pdf para export, react-helmet-async para SEO.
- **Backend / datos:** Supabase (Postgres + Auth + Edge Functions + RLS).
- **LLM:** todas las fases llaman a `ai.gateway.lovable.dev/v1/chat/completions` con `google/gemini-2.5-flash`. SSRF protection en el crawler (bloquea IPs privadas y metadata endpoints).
- **i18n:** LanguageContext con `es` (default) y `en`. Toda la UI y todos los prompts aceptan `outputLanguage`.

### Pipeline — 7 fases secuenciales, orquestadas en cliente (`useAnalysisOrchestrator.ts`)

1. **phase-1-market-analysis** — input: URL, descripción, competidores, docs, contexto, vision/mission/values, tone, brandVoice, industry. Output: `clientReadiness` (score + maturity + recommendation), `productUnderstanding`, `positioning`, `productNucleus` (incluye `summary.brandName`).
2. **phase-2-buyer-persona** — recibe brandInfo + marketData. Devuelve `profile` con `reliability` (0-100) que alimenta `avatarReliability`.
3. **phase-3-value-equation** — produce 3+ ofertas rankeadas con `valueGauge.value` (top 3 se muestran en `ProductMetrics`).
4. **phase-4-disc-translator** — adapta messaging a los 4 estilos DISC.
5. **phase-5-emotional-triggers** — dispara el **signup gate** al terminar: si `!user && currentPhase >= 5` se muestra `SignupGate` y se bloquea phase 6+ con blur (`#locked-content`). El gate asocia el `project.id` al `user.id` tras registro.
6. **phase-6-channel-strategy** — gateada por `BudgetInput` (`awaitingBudgetInput`). Output: 4+ canales rankeados con CPL estimado, pros/cons, `recommendation.primary/secondary/tertiary`, y `platformDetails` (adTypes, organicBoost, budgetSplit) para canales "nativos".
7. **phase-7-creative-variations** — genera variaciones creativas para test A/B; el primer item expone `nextAction` ("Test: {effect} on {channel}").

Cada fase persiste su payload en `phase_outputs(project_id, phase, payload)`. Schema tiene CHECK `phase BETWEEN 1 AND 7` (migration `phase0_stabilize`).

### Modelo de captura (lead magnet)

- **Sin auth:** el input inicial crea un `projects` row con `user_id=null` y un `session_token` (UUID) generado vía `getOrCreateSessionToken()` y guardado en localStorage. `saveUnclaimedProject(project.id)` lo retiene para reclaim.
- **Email capture independiente:** tabla `email_leads` (migration phase0) con `source IN ('pdf_download','phase_5_email_only','hero','other')`. RLS: cualquiera puede insertar; solo `admin_users` puede leer. Usada para el download del PDF (`downloadAnalysis.ts`) y para el gate de phase 5.
- **Reclaim:** `claimProjects.ts` y `/projects` requieren auth. La migración añade `is_valid_session_token` a la RLS de `projects`.

### UX / flujo

- `/` Index: Hero con form, ejecuta las 7 fases con auto-scroll a la sección de la fase completada, ribbon de fases flotante, export a PDF.
- `/auth`, `/projects` (auth), `/settings` (auth), `*` NotFound.
- Modo demo: `?demo=true` carga `mockData`; `?dev=TRUE` muestra banner amarillo con botón "Cargar Datos Mock" (ahorra créditos Lovable AI).
- i18n `es`/`en` global.

### Estado real — qué hay hecho y qué no

**Hecho y funcionando:**
- Las 7 Edge Functions desplegadas con validación Zod input + output schemas, SSRF guard, LLM call a Gemini 2.5 Flash vía gateway.
- DB schema completo: `projects`, `phase_outputs`, `email_leads`, `admin_users`; RLS configurado; CHECK constraint de phase 1-7 fixeado.
- UI completa con magic-reveal, ribbon flotante, blur sobre contenido locked, export PDF, demo mode.
- Captura de email_leads frictionless (no auth).
- i18n es/en operativa.

**Gaps / cosas que el nombre "GTM-DaybyDay" implica pero el código no refleja todavía:**
- El código se llama **"GTM Factory"** (footer, llms.txt, README Lovable). No hay rebranding visible a "GTM-DaybyDay" ni al sub-brand DaybyDay.
- El cliente prometido es "pegar la URL y el sistema analiza + crawlea internet para presencia online". **El crawler no está implementado en este repo**: phase 1 acepta la URL y un bloque de texto con `competitors/docs/context/vision/mission/values/tone/brandVoice` que el usuario rellena a mano. No hay un scraper de LinkedIn, redes, ads libraries, etc.
- No hay linkedin-magnet-style `/llms.txt` de un GTM-DaybyDay sub-product — solo el genérico de GTM Factory.
- No hay skill/contexto en `~/.config/opencode/skills/DaybyDay-Lead-Magnets/gtm-daybyday/` aún (sería carga del agente).

## Goals activos

- [x] **Rebrand de "GTM Factory" → "GTM-DaybyDay"** en código (footer, llms.txt, README, copy) — hecho 2026-06-12, ver decisions.md
- [x] **Crear skill del sub-folder** en `~/.config/opencode/skills/DaybyDay-Lead-Magnets/gtm-daybyday/SKILL.md` — hecho
- [x] **Email-only gate (no account)** — `EmailGate.tsx` creado, wired en `Index.tsx` como default con account signup como secundario
- [x] **Scaffold del crawler** — `supabase/functions/enrich-company/index.ts` creado (web-search LLM + Google CSE/KG opcionales por env)
- [x] **Wire `enrich-company` en el orchestrator** — llama antes de phase 1, pasa `enrichmentContext` en el body, persistido en `phase_outputs.payload._enrichment`
- [x] **Phase 1 acepta `enrichmentContext`** — schema Zod extendido, bloque inyectado en el prompt entre el website scrape y los additional inputs
- [ ] **Setear env vars de Google** (`GOOGLE_CUSTOM_SEARCH_ENGINE_ID`, `GOOGLE_CUSTOM_SEARCH_API_KEY`, `GOOGLE_KNOWLEDGE_GRAPH_API_KEY`) y verificar calidad del enrichment en un par de proyectos reales
- [x] **Cutover desde Lovable a Supabase nuevo + Cloudflare Pages** — hecho 2026-06-12
- [ ] **Probar el flujo end-to-end** en `https://gtm-daybyday.daybydayconsulting.com/` con un submission real
- [ ] **Ajustar el renderer del orchestrator** para extraer mejor la data de cada phase (actualmente cae en fallback corto cuando los keys no coinciden)
- [ ] **Recargar Gemini API** o quitarla del fallback (actualmente sin créditos)
- [ ] **Setear el Cloudflare AI Gateway provider** si se quiere logging + caching delante de MiniMax
- [ ] Definir el output exacto del reporte GTM (formato, profundidad, secciones) — qué se entrega como PDF/portal
- [ ] Validar con 2-3 negocios reales de prueba (pipe actual ya corre con mock data)
- [ ] Migrar dominio propio fuera de `gtm-dbd.lovable.app` (cuando se quiera cortar el cordón con Lovable)

## Decisiones clave

- **Stack confirmado:** Supabase + Lovable AI gateway + Gemini 2.5 Flash como LLM.
- **Lead model:** anon-first con `session_token`; email_leads frictionless; auth solo para persistir/reclamar.
- **7 fases son la unidad de valor** — no fusionar.

Ver [decisions.md](./decisions.md).

## Log reciente
