# DaybyDay-Blogpost-System

> Volcar aquí el estado actual del proyecto: qué es, qué versión, qué sigue.
> El agente actualiza este fichero cuando una decisión cambia el rumbo.

## Estado actual

Repo `DaybyDayWeb-HTML` (Pablo + Jorge). Pipeline Hormozi de 13 scripts, 124 .md en `content/`, 2/124 pipeline-ready y en producción (`que-es-un-growth-partner` y `cuando-necesitas-un-growth-partner`, prioridad 0.8 en sitemap). 122 legacy pendientes de decisión (reescribir ~240h o desindexar/borrar) — **pero `feat/static-pipeline` ya empezó: 10/85 reescritos en 2 commits diverged, sin mergear**.

**Rama activa**: `main` (SHA `6811537`). 6 commits sobre `ca521a4` (los 4 de PR #10 + 1 de PR #11 + 1 de PR #12):

| # | SHA | Qué |
|---|---|---|
| 1 | `a50d32d` | skip legacy en `--all` |
| 2 | `574ebd0` | verify-internal-links.mjs gate (truncado en línea 99) |
| 3 | `67ccba0` | IndexNow TODO doc |
| 4 | `cc3e543` | refactor `parseFrontmatter` → `lib/frontmatter.mjs` |
| 5 | `d730429` | fix truncamiento verify-internal-links + whitelist favicon (PR #11) |
| 6 | `6811537` | orquestador `scripts/rewrite-batch.mjs` (PR #12) |

**Ramas activas (2)**:
- `main` (`6811537`) ← **HEAD productivo, los 6 gates funcionales + orquestador**
- `master` (`a7b2690`) — implementación vieja pre-pipeline, candidata a borrar (decisión del operador)

**Inventario legacy** (post-PR #12): **85 posts** con `migration_state: "rendered"`, no 122 como estimaba la sesión 1 (la cifra original era pre-PR #10, antes de que el parser unificado con escape normalization distinguiera los estados). Inventario completo en `log/2026-06-12-audit-verify-hormozi.md`. Lote de arranque de **10 posts** seleccionado por el operador para ejecutar a las 22:00.

**Remote local** sigue como HTTPS con la fine-grained PAT (cambiado del SSH original `github-daybyday`).

## Goals activos

- ✅ PR + merge de `feat/pipeline-hardening` → `main` (PR #10)
- ✅ Verificación E2E de los 2 Hormozi contra los 6 gates del pipeline
- ✅ PR #11 mergeado: fix del truncamiento de `verify-internal-links.mjs` + whitelist de `favicon.ico`
- ✅ PR #12 mergeado: orquestador `scripts/rewrite-batch.mjs` para automatizar el ciclo de los 6 gates
- ✅ `feat/static-pipeline` descartada y borrada
- ✅ Limpieza de ramas residuales (4 borradas)
- 🆕 **Reescribir 10 posts legacy con la fórmula Hormozi validada** — **EN CURSO a las 22:00 CEST** (handoff capturado en `log/2026-06-12-handoff-2200.md`)
- 🆕 **Borrar `master`** (cleanup trivial)
- ⏳ Rotación de IndexNow key a `.env` (TODO documentado en patch 3, deferida)
- ⏳ GSC push real con JWT + URL Inspection API (declarado stub, ~1 día de trabajo)
- ⏳ Spell check ES, accesibilidad AA, validación JSON-LD, performance/Lighthouse, OG image default 1200×630, traducción EN, fix `primary_keyword:` regex bug en `migrate-legacy.mjs:23`
- ⏳ 75 legacy restantes (después del lote de 10)

## Decisiones clave

Ver [decisions.md](./decisions.md). Últimas decisiones tomadas el 2026-06-12 sobre los patches, el refactor, el modo WARN del skip, y la rotación deferida.

## Log reciente

- [2026-06-12 · Pipeline hardening rama feat/pipeline-hardening](./log/2026-06-12-pipeline-hardening.md) — 3 patches aplicados + refactor `parseFrontmatter`, 4 commits pusheados, PR pendiente de abrir
- [2026-06-12 · Handoff a las 22:00 con límites fresh](./log/2026-06-12-handoff-2200.md) — snapshot del repo, lote de 10 legacy confirmado, fórmula Hormozi, comandos de arranque, plantilla de rewrite, riesgos
- [2026-06-12 · Auditoría + verificación E2E Hormozi + fix verify-internal-links + descarte feat/static-pipeline](./log/2026-06-12-audit-verify-hormozi.md) — PR #10 ya mergeado, Hormozi pasan los 6 gates, bug de truncamiento en `verify-internal-links.mjs` reparado, fórmula Hormozi validada, PR #12 mergeado con orquestador, lote de 10 legacy seleccionado para las 22:00


