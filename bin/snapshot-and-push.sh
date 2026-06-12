#!/usr/bin/env bash
# opencode-brain scheduled push
# Called by launchd Mon/Thu 19:00. Wraps the plugin's --push with logging.
# Never blocks the agent: always returns 0 unless git is broken.

set -u

PLUGIN="$HOME/.config/opencode/plugins/opencode-brain.ts"
LOG_DIR="$HOME/Library/Logs/opencode-brain"
LOG_FILE="$LOG_DIR/push.log"
mkdir -p "$LOG_DIR"

ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
log() { printf "[%s] %s\n" "$(ts)" "$*" | tee -a "$LOG_FILE" ; }

log "===== snapshot-and-push start ====="

# Pick a TS runtime. Prefer bun, fall back to node + --experimental-strip-types.
run_plugin() {
  if command -v bun >/dev/null 2>&1; then
    bun "$PLUGIN" "$@"
  else
    node --experimental-strip-types "$PLUGIN" "$@"
  fi
}

if ! command -v bun >/dev/null 2>&1 && ! command -v node >/dev/null 2>&1; then
  log "ERROR: neither bun nor node on PATH; cannot run plugin"
  exit 0
fi

if ! command -v git >/dev/null 2>&1; then
  log "ERROR: git not on PATH"
  exit 0
fi

REPO="$HOME/Developer/OpenCode-Brain"
if [ ! -d "$REPO/.git" ]; then
  log "ERROR: $REPO is not a git repo"
  exit 0
fi

# 1. Check status first — if there are no local commits ahead, do nothing.
status_output="$(run_plugin --status 2>&1)"
if ! echo "$status_output" | grep -q '"commitsAhead"'; then
  log "ERROR: --status did not return JSON; aborting"
  log "--- raw output ---"
  echo "$status_output" >> "$LOG_FILE"
  exit 0
fi

commits_ahead=$(echo "$status_output" | sed -n 's/.*"commitsAhead": \([0-9]*\).*/\1/p')
log "commits ahead of origin: ${commits_ahead:-0}"

if [ "${commits_ahead:-0}" -eq 0 ]; then
  log "nothing to push, exiting"
  exit 0
fi

# 2. Dry-run first to surface secret-check failures into the log.
dryrun_output="$(run_plugin --push --dry-run 2>&1)"
log "dry-run output:"
echo "$dryrun_output" >> "$LOG_FILE"

if echo "$dryrun_output" | grep -q '"reason": "secret"'; then
  log "ABORT: secret check failed; not pushing. Inspect log and run:"
  log "  bun $PLUGIN --status"
  log "  bun $PLUGIN --push --dry-run"
  exit 0
fi

if echo "$dryrun_output" | grep -q '"ok": false'; then
  log "ABORT: dry-run reported failure; not pushing"
  exit 0
fi

# 3. Real push.
push_output="$(run_plugin --push 2>&1)"
log "push output:"
echo "$push_output" >> "$LOG_FILE"

if echo "$push_output" | grep -q '"ok": true'; then
  log "OK: pushed ${commits_ahead} commits"
else
  log "PUSH FAILED: see output above"
fi

log "===== snapshot-and-push end ====="
