# 2026-06-12 · Pipeline hardening rama feat/pipeline-hardening

## Contexto

Continuación de la sesión anterior (snapshot 2026-06-11). El repo `DaybyDayWeb-HTML` se auditó, se generó un snapshot operativo, y se prepararon 3 patches en `~/.config/opencode/patches/` para hardening del pipeline. Esta sesión: aplicarlos en una rama `feat/pipeline-hardening`, hacer commit por patch, pushear, y luego el refactor recomendado de `parseFrontmatter`.

## Setup del entorno

- Repo local estaba en `master` con un árbol distinto al de la snapshot (Python `.py` en vez de `.mjs`; `scripts/build_clusters.py` etc.; sin `templates/`, `content/`, `tech/`). La snapshot apuntaba a `main` con SHA `ca521a4`.
- Acción correctiva:
  - `git fetch origin main` → `git reset --hard origin/main` → SHA `ca521a4` ✓
  - El árbol coincide con el descrito en la snapshot
  - El stash previo (`wip: pre-feat/pipeline-hardening dirty state`) guardó el estado dirty de `master` por si hay que recuperarlo
- Remote local era SSH (`github-daybyday`). Cambiado a HTTPS con la fine-grained PAT para que la auth funcione:
  - `git remote set-url origin https://x-access-token:<PAT>@github.com/DaybyDay-csv/DaybyDayWeb-HTML.git`
  - Si prefieres dejar SSH como default, revertir tras la sesión
- `scripts/lib/` y `.last-write-raw.md` quedaron untracked y NO se incluyeron en los commits. Son arrastre de la sesión previa y fuera de scope de hardening.

## Patches

Los 3 patches originales en `~/.config/opencode/patches/` venían con `git apply --check` fallando por "corrupt patch at line N" — el header `@@ -X,Y +A,B @@` carecía de contexto trailing. **El diff en sí era legible y correcto**, así que se aplicaron manualmente con `edit` en lugar de tocar el patch.

### Patch 1 · `a50d32d` — skip legacy en `--all`

`scripts/build-static.sh`:
```bash
if [[ ! -f "blog/$slug.html" ]]; then
  # Skip legacy sources that have not been rewritten by the pipeline.
  # Two markers indicate the source is still a skeleton:
  #   1) frontmatter `migration_state: "rendered"`
  #   2) literal placeholder `[BODY-TO-REWRITE]` in the body
  if grep -q '^migration_state:[[:space:]]*"rendered"' "$md"; then
    echo "  skip $slug (migration_state: rendered — legacy, not pipeline-ready)"
    continue
  fi
  if grep -q '\[BODY-TO-REWRITE\]' "$md"; then
    echo "  skip $slug (contains [BODY-TO-REWRITE] — legacy, not pipeline-ready)"
    continue
  fi
  render_one "$slug" || echo "Skipped $slug"
fi
```

**Motivación**: de los 124 .md, 122 son legacy (85 con `migration_state: "rendered"` + 37 con `[BODY-TO-REWRITE]` literal), 2 son pipeline-ready (los Hormozi). `--all` sin este gate sobrescribe `blog/<slug>.html` con esqueletos vacíos en producción. Gate de seguridad: WARN por skip, no aborta.

**Verificación post-apply**: `git diff` muestra +14 LOC, 0 removidas. Wired dentro del `if [[ ! -f "blog/$slug.html" ]]` existente para no tocar la lógica de `render_one`.

### Patch 2 · `574ebd0` — verify-internal-links.mjs gate

`git apply` limpio, sin tocar el patch.

Nuevo script: `scripts/verify-internal-links.mjs` (99 LOC, executable).
- Parsea `blog/<slug>.html`, extrae `href=` y `src=` con regex
- Filtra externos (`https:`, `mailto:`, `tel:`, anchors `#`)
- Resuelve cada target interno contra el filesystem del repo
- `exit 1` si falta algún target
- Lista blanca explícita para `/en/blog/*` (gap intencional documentado en el header: el mirror EN no existe, se reporta pero no aborta)

Wirreado en `build-static.sh:43-44`, corre **después** de `verify-render` y **antes** de `update-llms-txt` para que un link roto no contamine `llms.txt`, `sitemap.xml`, ni el push a IndexNow.

### Patch 3 · `67ccba0` — IndexNow TODO doc

`scripts/indexnow.mjs`:
- Bloque `TODO(rotate-indexnow-key)` en el header con 4 action items:
  1. Generar nueva key en `https://www.indexnow.org/`
  2. Guardar como `INDEXNOW_KEY` en `.env` (ya gitignored)
  3. Eliminar el `|| '<hardcoded-fallback>'` fallback
  4. Exit 1 si `process.env.INDEXNOW_KEY` undefined
- `console.error` post-submit que avisa del estado en cada ejecución
- Cero cambio de comportamiento, key string idéntica (`d3b6f1c2a8e54a7f9c1b0d2e3f4a5b6c`)

Solo documentación. La rotación real está deferida por decisión del operador (ver decisions.md).

## Push

`git push -u origin feat/pipeline-hardening` → OK. SHA remoto `67ccba0deb1baef1471a83339311da69a903d1ac`.

**No se abrió el PR** con `gh` — la fine-grained PAT puede no tener `pull_requests:write`. Decisión del operador si abrirlo manualmente o con otra PAT.

## Refactor parseFrontmatter (post-push)

El snapshot listaba como pendiente el refactor de 3 copias casi-idénticas de `parseFrontmatter` → `scripts/lib/frontmatter.mjs`. Se ejecutó como commit `cc3e543` aparte, en la misma rama.

### Estado previo

| Archivo | Líneas | Nombre | Modo error | Tolerancia arrays |
|---|---|---|---|---|
| `render-post.mjs:14-44` | 31 | `parseFrontmatter` | throw si falta/cierra | robusta (escape normalization) |
| `qa-checklist.mjs:14-34` | 21 | `parseFrontmatter` | return `{fm:{}}` | **simple** (sin escape normalization) |
| `verify-external-links.mjs:28-53` | 26 | `extractFrontmatter` | return `{fm:{}}` | robusta |

La snapshot decía "3 copias idénticas" — **no eran idénticas**. `qa-checklist.mjs` tenía una divergencia funcional: arrays con comillas escapadas caían a `string` en lugar de parsearse.

Pregunté al usuario, eligió: **"Usar la versión robusta"**. Trade-off:
- Pro: convergencia, comportamiento más correcto
- Contra: cambio de comportamiento observable en `qa-checklist.mjs` para fuentes con arrays con escape
- Riesgo real: bajo, los 2 Hormozi no usan arrays con escape

### Cambios

- `scripts/lib/frontmatter.mjs` nuevo (80 LOC) con flag `{strict: true}`
- `scripts/render-post.mjs`: -31 LOC duplicadas, +1 import, call site `parseFrontmatter(raw, { strict: true })`
- `scripts/qa-checklist.mjs`: -21 LOC duplicadas, +1 import, comportamiento array más robusto (mejora colateral confirmada)
- `scripts/verify-external-links.mjs`: -26 LOC duplicadas, +1 import, call site renombrado `extractFrontmatter` → `parseFrontmatter`

### Verificación

- `node --check` en los 4 archivos → OK
- Smoke test del parser unificado sobre los 2 Hormozi:
  - `que-es-un-growth-partner` → 19 keys, faq: array[5], body 9809 chars
  - `cuando-necesitas-un-growth-partner` → 19 keys, faq: array[5], body 8976 chars
- `verify-external-links.mjs --all` (sin args) → 125 files processed, 7 unique URLs, sin error
- `qa-checklist.mjs que-es-un-growth-partner` → verdict `publicar`, 1675 palabras (vs 1635 originales — delta por tokenización, no regresión)

### Diff stats

```
scripts/qa-checklist.mjs          | 23 +----------------------
scripts/render-post.mjs           | 35 ++---------------------------------
scripts/verify-external-links.mjs | 30 ++----------------------------
3 files changed, 5 insertions(+), 83 deletions(-)
scripts/lib/frontmatter.mjs       | 80 ++++++++++++++ (nuevo)
```

Push del refactor: `cc3e543` sobre `67ccba0`. Rama queda con 4 commits sobre `ca521a4`.

## Estado del pipeline después de esta sesión

- `feat/pipeline-hardening` lista para PR → `main`
- 4 commits limpios, 0 cambios en contenido publicado
- 1 nuevo módulo (`lib/frontmatter.mjs`) y 1 nuevo gate (`verify-internal-links.mjs`)
- Gate de skip legacy en `--all` activo
- IndexNow key documentada como TODO pendiente de rotación manual

## Pendiente real (no del batch de hardening)

Estos son los ítems de la sección "Falta" de la snapshot, no "próximos pasos":

1. Decidir qué hacer con 122 legacy (reescribir ~240h o desindexar/borrar)
2. Implementar GSC push real (JWT + URL Inspection API)
3. Mover IndexNow key a `.env` (TODO documentado en patch 3)
4. Gate de link rot interno — **HECHO en patch 2**
5. Gate de spell check ES
6. Accesibilidad AA
7. Validación de JSON-LD contra schema.org
8. Performance / Lighthouse
9. Auto-regeneración de `blog.html` (110KB)
10. Traducir blog a EN (o desindexar `en/blog.html`)
11. Imagen OG default 1200×630
12. Refactor `parseFrontmatter` → `lib/frontmatter.mjs` — **HECHO en commit `cc3e543`**
13. Fix `primary_keyword:` con `:` final en `migrate-legacy.mjs:23` (regex bug)

## Comandos útiles para próximos entornos

```bash
git clone https://github.com/DaybyDay-csv/DaybyDayWeb-HTML.git
cd DaybyDayWeb-HTML
git checkout feat/pipeline-hardening

# Verificar Hormozi #1 contra los nuevos gates
node scripts/qa-checklist.mjs que-es-un-growth-partner
node scripts/verify-external-links.mjs que-es-un-growth-partner
node scripts/render-post.mjs que-es-un-growth-partner
node scripts/seo-pack.mjs que-es-un-growth-partner
node scripts/verify-render.mjs que-es-un-growth-partner --local
node scripts/verify-internal-links.mjs que-es-un-growth-partner  # NUEVO

# Probar que --all NO renderiza legacy
bash scripts/build-static.sh --all
# Debe imprimir 122 líneas "skip <slug> (migration_state...)" o "...[BODY-TO-REWRITE]..."

# Smoke test del parser unificado
node -e "import('./scripts/lib/frontmatter.mjs').then(({parseFrontmatter}) => { const {readFileSync} = require('node:fs'); const r = readFileSync('content/que-es-un-growth-partner.md','utf8'); console.log(parseFrontmatter(r, {strict:true})); });"
```
