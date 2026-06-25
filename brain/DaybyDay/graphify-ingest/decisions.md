# DaybyDay / graphify-ingest — Decisions

## 2026-06-19 — Initial setup

### Trust the local pipeline for sensitive files

You opted to send sensitive docs (NDAs, Pacto de Socios, Denuncia Policial,
Parte Médico, visas, FERRA recovery codes, WhatsApp zips) to MiniMax API
for semantic extraction, trusting the local pipeline. No redaction pass
was added. If you change your mind later, run with
`GRAPHIFY_REDACT_SENSITIVE=1` and re-extract affected buckets only.

### Single graph, DaybyDay as gravitational center

You chose to build one unified graph (not per-project sub-graphs) so
cross-project discovery is the primary use case. DaybyDay appears across
nearly every project folder so it naturally surfaces as the highest-
centrality god node.

### Mirror via symlinks, not copies

Symlinks save ~12 GB of disk and keep a single source of truth. Trade-off:
if iCloud or local files move/delete, symlinks dangle. The runner skips
dangling symlinks gracefully (logs them as `errors` in progress.json).

### Content-hash dedup across buckets

Some files (e.g. Cartri logos appearing in both Cartri folder and
DaybyDay's "Logos Clientes" folder) are byte-identical across buckets.
Hash-based dedup keeps them in the highest-priority bucket (per
`project_priority.tsv`) and writes a `.dedup→<winner>` sentinel in
lower-priority buckets. Cross-bucket context preserved without
double-counting.

### Adaptive 5h batches (not single overnight)

Your MiniMax Plus quota is a 5h rolling window. Single overnight runs risk
hitting the wall mid-file. Runner exits cleanly at 4h45m wall-clock,
leaving 15 min margin. Subsequent runs auto-resume from `progress.json`.

### Skip media files (audio/video/HEIC)

You opted to skip MP3/M4A/WAV/MOV/MP4/HEIC and document them in the
coverage report rather than install transcription extras. They consume
~95% of disk in FERRA/Douf/LVP but yield ~0% text for graphify.

### MiniMax M3 with thinking enabled

`graphify --mode deep` uses thinking-mode by default. The smoke test
confirmed reasoning tokens (`completion_tokens_details.reasoning_tokens`)
are being used. If a single run shows quota pressure (response time >30s
for 3 consecutive calls), the runner pauses with `paused_quota_pressure`.

### opencode-brain bridge via `#DaybyDay/graphify-ingest`

Added as a sub-folder of DaybyDay (not a new top-level project) because
DaybyDay is the gravitational center of the graph and the valid project
slugs list in the opencode-brain plugin is hard-coded.

## Open questions

- After the first full run, should we re-run with `--no-thinking` to get a
  cheaper second pass that catches any nodes the thinking-mode run missed?
- Should we re-extract just the `personal` and `inbox` buckets with
  `GRAPHIFY_REDACT_SENSITIVE=1` once a redaction pass is built?
- Cross-bucket dedup sentinels (`.dedup→<winner>`) are currently just text
  files. Should they be symlinks pointing at the winner instead, so
  graphify treats them as the same node?