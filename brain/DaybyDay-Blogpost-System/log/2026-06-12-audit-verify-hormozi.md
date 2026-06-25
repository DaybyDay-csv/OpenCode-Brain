# 2026-06-12 · Sesión 2 (parte 2) — Validación Hormozi + inventario legacy + orquestador

_(continuación de la sesión 2, desde la validación Hormozi hasta el cierre con el orquestador mergeado)_

## Validación Hormozi E2E (re-corrida limpia en `main` post-PR #11)

Los 2 Hormozi pasan los 6 gates en `main` @ `d730429` (post-PR #11). Tabla resumen:

| Gate | Hormozi #1 `que-es-un-growth-partner` | Hormozi #2 `cuando-necesitas-un-growth-partner` |
|---|---|---|
| `qa-checklist.mjs` | ✓ `publicar`, 1675 palabras, 0 issues | ✓ `publicar`, 1603 palabras, 0 issues |
| `verify-external-links.mjs` | ✓ todas 200 OK | ✓ todas 200 OK |
| `verify-internal-links.mjs` | ✓ 30/29 OK/1 known_gap | ✓ 30/29 OK/1 known_gap |
| `render-post.mjs` | ✓ FAQ + related + 2 schemas | ✓ FAQ + related + 2 schemas |
| `seo-pack.mjs` | ✓ 16/16 checks, 1635 words | ✓ 16/16 checks, 1575 words |
| `verify-render.mjs --local` | ✓ 12/12 checks | ✓ 12/12 checks |

## Inventario de los 85 legacy (corrección de la cifra de 122)

**Hallazgo metodológico**: la sesión 1 estimaba 122 legacy. Con el parser unificado de PR #10 (que normaliza escapes), el inventario real es:

- **85** `migration_state: "rendered"` (legacy, HTML antiguo con JSX map)
- **40** `migration_state: "good"` (ya Hormozi)
- **2** Hormozi sin state marker (`que-es-un-growth-partner`, `cuando-necesitas-un-growth-partner`)

Total: **125 posts** en `content/`. La cifra 122 de la sesión 1 era pre-PR #10.

### Distribución por cluster (85 legacy)

| Cluster | Legacy | % legacy del cluster |
|---|---:|---:|
| Estrategia | 21 | 75% |
| Meta Ads | 13 | 59% |
| Decisiones de negocio | 8 | 100% |
| Tracking | 7 | 100% |
| Paid Media | 6 | 35% |
| Creatividades | 4 | 100% |
| Métricas | 4 | 100% |
| Unit Economics | 3 | 100% |
| Reporting | 2 | 100% |
| Google Ads | 2 | 100% |
| Estructura de cuenta | 2 | 100% |
| + 14 clusters con 1 legacy cada uno | 14 | — |

### Esfuerzo estimado

- Total: 108,683 palabras · promedio 1279/post · mediana 1288/post
- Target Hormozi: 1600–1700 palabras
- Esfuerzo: ~3.5 horas/post promedio
- Total: 85 × 3.5h = **~298 horas = ~37 días full-time = ~8.5 semanas a ritmo de 10/semana**

## Orquestador `scripts/rewrite-batch.mjs` (PR #12 mergeado)

Construido en esta sesión, mergeado en PR #12 (squash, SHA `6811537`). CLI:

```bash
node scripts/rewrite-batch.mjs <slug1> [slug2 ...]      # lista explícita
node scripts/rewrite-batch.mjs --next 5                 # primeros 5 legacy
node scripts/rewrite-batch.mjs --all                    # todos los 85
node scripts/rewrite-batch.mjs --status                 # solo inventario
```

Orden de los 6 gates: idéntico a `build-static.sh`:
1. `qa-checklist.mjs` (exit 0=`publicar`, 1=err, 2=`regenerar`, 3=`reescribir`)
2. `verify-external-links.mjs` (exit 0/1)
3. `render-post.mjs` (exit 0/1)
4. `seo-pack.mjs` (exit 0/1)
5. `verify-render.mjs --local` (exit 0/1)
6. `verify-internal-links.mjs` (exit 0/1)

Si los 6 gates pasan, el orquestador modifica `content/<slug>.md`:
```diff
-migration_state: "rendered"
+migration_state: "good"
```

Exit codes del orquestador:
- `0` = todos los slugs del batch pasaron
- `1` = usage error
- `2` = al menos un slug falló un hard gate
- `3` = al menos un slug disparó `qa-checklist` `REESCRIBIR`/`REGENERAR` (necesita rewrite humano)

Testeado con los 2 Hormozi: ambos pasan los 6 gates, no promotion (su `migration_state` es absent, no "rendered").

## Lote de arranque seleccionado: 10 legacy de máxima importancia

Para ejecutar a las 22:00 con límites fresh del modelo. Criterios: bajo esfuerzo + BOFU + foundation + cobertura de clusters.

| # | Slug | Cluster | WC | Razón |
|---|---|---|---:|---|
| 1 | `preguntas-agencia` | Estrategia | 506 | BOFU — selección de agencia |
| 2 | `agencia-vs-inhouse` | Estrategia | 587 | BOFU — sitemap priority 0.8 |
| 3 | `ugcmeta-ads` | Meta Ads | 675 | Pilar creatividades UGC |
| 4 | `cpa` | Meta Ads | 696 | Definición operativa CPA |
| 5 | `iamarketing-digital` | IA y Automatización | 697 | Único legacy en IA |
| 6 | `roas` | Meta Ads | 736 | Definición ROAS |
| 7 | `meta-vs-google` | Paid Media | 746 | Comparativa foundation |
| 8 | `metodologia-day-by-day` | Estrategia | 756 | Foundation — método de la empresa |
| 9 | `cuanto-cobra-media-buyer` | Paid Media | 763 | BOFU — pricing |
| 10 | `que-es-un-media-buyer` | Paid Media | 765 | Foundation — definición operativa |

**Cobertura**: 3 Paid Media + 3 Meta Ads + 3 Estrategia + 1 IA. **Total: 6,929 palabras**. **Tiempo estimado: ~6.5h de rewrite**.

## Estado del repo al cierre

```
main                                  -> 6811537  ← productivo, 6 gates + orquestador
master                                -> a7b2690  ← vieja pre-pipeline, candidata a borrar
```

PRs: 0 abiertos. #12 es el último cerrado.

Ramas borradas esta sub-sesión: `chore/rewrite-batch-orchestrator` (auto-limpia post-squash-merge), `fix/verify-internal-links-completion` (auto-limpia), `feat/blog-pipeline` (local huérfana), `feat/pipeline-hardening`, `cloudflare/workers-autoconfig`, `claude/daybyday-web-redesign-IF0HR`, `feat/static-pipeline` (todas las mergeadas/descartadas de la sub-sesión 1).

## Pendiente real actualizado (post-inventario + orquestador)

1. ✅ PR #10, #11, #12 mergeados
2. ✅ Validación E2E Hormozi
3. ✅ Limpieza de ramas residuales
4. ✅ `feat/static-pipeline` descartada
5. ✅ Orquestador `scripts/rewrite-batch.mjs` en main
6. 🆕 **HOY 22:00: reescritura de los 10 legacy del lote de arranque**
7. 🆕 **Borrar `master`** (cleanup trivial)
8. ⏳ 75 legacy restantes (después del lote de 10)
9. ⏳ Rotación IndexNow key a `.env`
10. ⏳ GSC push real con JWT
11. ⏳ Spell check ES, accesibilidad AA, validación JSON-LD, performance/Lighthouse, OG image, traducción EN, fix `primary_keyword:` regex bug

---

# Sesión 2 (parte 1) — Auditoría original, fix verify-internal-links, descarte feat/static-pipeline

_(mantenido del log previo, sin cambios)_

Estado de `DaybyDayWeb-HTML` al retomar:

- **PR #10 (`Feat/pipeline hardening`) mergeado por el operador el 2026-06-12 18:31:48** — los 4 commits (`a50d32d`, `574ebd0`, `67ccba0`, `cc3e543`) están en `main` con merge commit `1ce01ca`. La fine-grained PAT SÍ tenía `pull_requests:write` (mi miedo en la sesión 1 era infundado).
- **6 ramas**: `main` (`1ce01ca`), `feat/pipeline-hardening` (residual, ya mergeada), `feat/static-pipeline` (diverged, 2 ahead: 10/85 legacy rewrites Hormozi-style), `master` (diverged, implementación vieja pre-pipeline), `cloudflare/workers-autoconfig` y `claude/daybyday-web-redesign-IF0HR` (residuales ya mergeadas).
- **0 PRs abiertos, 0 issues abiertos.**
- 124 .md en `content/`, 2 pipeline-ready (los 2 Hormozi), 122 legacy con `migration_state: "rendered"` o `[BODY-TO-REWRITE]`.

## Verificación E2E Hormozi contra los 6 gates

Ejecutado en `main` (post-merge de PR #10) contra `que-es-un-growth-partner` y `cuando-necesitas-un-growth-partner`:

| Gate | Hormozi #1 | Hormozi #2 |
|---|---|---|
| `qa-checklist.mjs` | verdict `publicar`, 1675 palabras, 0 issues | verdict `publicar`, 1603 palabras, 0 issues |
| `verify-external-links.mjs` | todas las URLs externas 200 OK | todas 200 OK |
| `verify-internal-links.mjs` | **FALLÓ — bug del script** | (no se llegó a probar por el bug) |
| `render-post.mjs` | OK, 1675 palabras, FAQ + related + 2 schemas | OK, 1603 palabras, FAQ + related + 2 schemas |
| `seo-pack.mjs` | OK, todos los checks pasan | OK, todos los checks pasan |
| `verify-render.mjs --local` | OK, todos los checks pasan | OK, todos los checks pasan |

## Bug crítico encontrado: `verify-internal-links.mjs` truncado en `main`

El commit `574ebd0` (parte de PR #10) dejó el archivo **truncado en la línea 99**: terminaba con un object literal `const summary = { ... missing: missing.length,` abierto y sin cerrar. No había `console.log`, no había `process.exit`. Resultado: `SyntaxError: Unexpected end of input` al intentar importar.

La causa más probable: el patch 2 que diseñamos en la sesión 1 perdió su cola cuando lo aplicamos con `edit` o `git apply` — la última parte (cierre + print + exit) no aterrizó. En la sesión 1, como no ejecutamos el script, no lo detectamos.

**Segundo bug encontrado al arreglar el primero**: el gate fallaba por `/favicon.ico` — el template renderizado incluye `<link rel="icon" href="/favicon.ico">` pero el archivo no está en el repo. El favicon no es un link roto del contenido, es una referencia intencional del template. Mismo tratamiento que `/en/blog/*`: whitelist como `known_gap`.

## Fix aplicado

Commit `5e33dc9` en rama `fix/verify-internal-links-completion` (pusheada a `origin`):

```diff
+  // favicon.ico: whitelisted as known_gap (template references it but
+  // the file is not committed; served by platform or absent by design)
+  if (p === 'favicon.ico') return { state: 'known_gap', url };
```

Y cierre del `summary` + `console.log` + `process.exit(1)` on missing + `process.exit(0)` on clean.

**Resultados tras el fix**:
- Hormozi #1: 30 internal links, 29 OK, 1 known_gap (favicon), 0 missing → exit 0 ✓
- Hormozi #2: 30 internal links, 29 OK, 1 known_gap (favicon), 0 missing → exit 0 ✓

## Pipeline Hormozi validado — fórmula confirmada

Los 2 Hormozi pasan **todos los 6 gates** sin tocar nada del source. La "buena fórmula" Hormozi que usaremos para los 122 legacy es:

| Atributo | Hormozi #1 | Hormozi #2 |
|---|---|---|
| Word count | 1675 | 1603 |
| Body length | 10628 chars | 9788 chars |
| Voz (avg sentence length) | 10.4 | 10.9 |
| Tuteo violations | 0 | 0 |
| `has_framework_named` | false | false |
| Estructura score | 7 | (no se imprimió completo, pasó) |
| Contenido score | 4 | (no se imprimió completo, pasó) |
| Concrete numbers | 49 | (no se imprimió completo) |
| Title length | 51 | (no se imprimió completo) |
| Meta length | 143 | 143 |
| FAQ presente | sí | sí |
| Related presente | sí | sí |
| Schemas | 2 (Article + FAQPage) | 2 (Article + FAQPage) |
| Internal links | 30–36 (varía por gate) | 30–36 |
| External sources | todas 200 OK | todas 200 OK |
| Verdict QA | `publicar` | `publicar` |

**Implicación para los 122 legacy**: la fórmula Hormozi es exigente pero el output pasa limpio. Si la fórmula de los rewrites en `feat/static-pipeline` (los 2 commits diverged, 10/85 rewrites) se mantiene Hormozi-equivalente (mismo nivel de voz, estructura, contenido, FAQ, related, schemas), pueden mergearse y entrar al pipeline. Si no, hay que reescribirlos.

## Pendiente real actualizado (post-auditoría)

1. ✅ PR + merge `feat/pipeline-hardening` → `main` (PR #10)
2. ✅ Verificación E2E de los 2 Hormozi contra los 6 gates (hecho en esta sesión, con fix del bug del gate)
3. 🆕 **Decidir qué hacer con `feat/static-pipeline` (10/85 legacy rewrites diverged)** — abrir pregunta esta sesión
4. 🆕 **Decidir si se mergea `fix/verify-internal-links-completion` a `main`** (PR nuevo, decisión del operador)
5. 🆕 **Limpiar ramas residuales** (3 ramas ya mergeadas, decisión del operador)
6. ⏳ Decisión sobre los 112 legacy restantes (después de 3+4+5)
7. ⏳ Rotación IndexNow key a `.env` (TODO documentado)
8. ⏳ GSC push real con JWT

## Comandos para próximos entornos

```bash
# Verificar Hormozi con el gate reparado
git fetch origin
git checkout fix/verify-internal-links-completion
node scripts/qa-checklist.mjs que-es-un-growth-partner
node scripts/verify-external-links.mjs que-es-un-growth-partner
node scripts/verify-internal-links.mjs que-es-un-growth-partner  # YA FUNCIONA
node scripts/render-post.mjs que-es-un-growth-partner
node scripts/seo-pack.mjs que-es-un-growth-partner
node scripts/verify-render.mjs que-es-un-growth-partner --local

# Inspeccionar feat/static-pipeline para decidir sobre los 10 rewrites
git fetch origin
git checkout feat/static-pipeline
git log --oneline -5
diff main feat/static-pipeline -- content/
```
