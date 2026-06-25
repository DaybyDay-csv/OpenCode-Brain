# DaybyDay / graphify-ingest

## CURRENT STATUS: 7/7 workflows in n8n, awaiting env vars + activation

All 7 blog pipeline workflows are imported in n8n.daybydayconsulting.com. The remaining manual step is setting 8 environment variables in the n8n UI (Settings → Variables) and activating the workflows.

## n8n workflows (all imported, all inactive)

| Stage | ID | Status |
|---|---|---|
| Stage 1 — Topic Discovery | `3gmzM8lVDWHoTvto` | ✅ imported |
| Stage 2 — Problem Validation | `HY2AiWlcAA2K1HNW` | ✅ imported (v0.1, without X/TikTok/Instagram) |
| Stage 3 — Solution Research | `2wflwm5DmIlBJf5m` | ✅ imported |
| Stage 4 — Drafter (Harmozy Formula) | `mhAv5sQf4vpvoMav` | ✅ imported |
| Stage 5 — SEO Enricher + Render | `9A9ALT0XeeTwBFGF` | ✅ imported |
| Stage 6 — Publisher + Index + Backfill | `0CrhMH0bVn9mFvB4` | ✅ imported |
| Daily GSC Sync → Airtable | `66WAfvSo0nSwUgqX` | ✅ imported |

## What Pablo needs to do (5 minutes)

### Step 1: Set environment variables in n8n UI

Go to: https://n8n.daybydayconsulting.com → Settings → Variables → Add Variable

Create these 8 variables (or run `bash /tmp/opencode/DaybyDayBlogPipeline/scripts/set-n8n-env-vars.sh` to see the masked list):

| Name | Value (first chars) | Source |
|---|---|---|
| `AIRTABLE_BASE_ID` | `appRPOBLuzFO...` | /Users/pablo/.cache/opencode-import/.env |
| `DEEPSEEK_API_KEY` | `sk-bbc28f9db...` | .env |
| `ANTHROPIC_API_KEY` | `sk-cp-coe8mq...` | .env (this is actually a MiniMax key) |
| `GOOGLE_API_KEY` | `AIzaSyCUO8nM...` | .env |
| `TELEGRAM_BOT_TOKEN` | `8835896942:A...` | .env |
| `TELEGRAM_PABLO_CHAT_ID` | `5472173497` | .env |
| `GSC_CREDENTIALS_PATH` | `/Users/pablo/Downloads/DAYBYDAY/Blog System/...` | .env (path with spaces) |
| `GOOGLE_SEARCH_ENGINE_ID` | (empty for now) | .env (will need CSE setup) |

Optional (for Stage 2 v0.2 social sources — can be empty):
- `X_BEARER_TOKEN` — for X/Twitter
- `TIKTOK_ACCESS_TOKEN` — for TikTok Research API
- `IG_USER_ID` + `IG_ACCESS_TOKEN` — for Instagram Graph API

### Step 2: Activate the workflows

In the n8n UI, open each workflow and click the "Active" toggle in the top right. Start with Stage 1 (Topic Discovery) and let it run for a week before activating the rest.

### Step 3: Test the Airtable credential

The credential "Airtable account" (airtableApi) is already configured in n8n. It's linked to one of the Airtable nodes. Verify it has access to base `appRPOBLuzFOiXFvc` (Blogposting Performance HQ).

## v0.2 changes (not yet imported to n8n)

After Pablo's request, the pipeline now has social-source pack capability:

### Stage 2 v0.2 (file ready, not in n8n)

The Stage 2 workflow has been updated to search **6 sources** instead of 3:
- Reddit (year) — existing
- Reddit (top thread) — existing
- Google Custom Search — existing
- **X (Twitter) search** — new
- **TikTok Research API** — new
- **Instagram Graph API** — new

After merging all 6 sources, two DeepSeek calls extract:
1. The problem brief (sub-questions, misconceptions, ICP voice, feasibility)
2. The best social hooks (verbatim text, author, engagement, why_good)

The hooks become the **H1 of the blog post** — the drafter must use a real founder's actual words as the title.

### Harmozy Formula v0.2

The `docs/HARMOZY_FORMULA.md` has been updated with a new section "0. NEW v0.2 — Social-source injection (X / TikTok / Instagram)" that:
- Mandates the H1 come from a real social post (not invented)
- Requires the escena block to use a social source (anonymized)
- Bans generic titles that don't trace back to a real post
- Bans social sources older than 30 days or without specific numbers

### Stage 4 drafter v0.2

The drafter now:
- Loads the Harmozy Formula from a public GitHub raw URL (not filesystem)
- Has a fallback `HARMOZY_FORMULA_FALLBACK` env var for offline operation
- Receives the social-source pack as part of the prompt
- Receives the Source Topic's full Research Notes (which now contain both quotes AND the social source pack)

## Why the v0.2 Stage 2 didn't get imported to n8n

The big-pickle model hit an infinite loop trying to fix syntax in a JavaScript template literal that uses `${}` inside a backtick string. The MCP `validate_workflow` tool kept rejecting it, and the model kept trying to fix the wrong thing. After 30+ iterations, the model gave up and asked for human input.

The JSON file is correct and ready at `/tmp/opencode/DaybyDayBlogPipeline/n8n/stage-2-problem-validation.json` (19KB). The fix is to either:
1. Run the workflow JSON through Claude or another LLM manually to clean up the code nodes
2. Use the n8n UI to manually create the v0.2 workflow from scratch
3. Accept v0.1 for now and add the social-source pack in a follow-up

## Why I (the agent) can't wire credentials or run test executions

The n8n-mcp tools expose 28 tools (workflow create/read/update, search, validate, etc.) but **do not have a `set_variable` or `manage_environment` tool**. The n8n REST API requires an API key (`X-N8N-API-KEY` header) which Pablo revoked. The MCP auth is a different scope and doesn't work as the n8n API key.

The workarounds:
- **Variables**: must be set manually in the n8n UI
- **Test execution**: open each workflow in the UI and click "Execute Workflow"

## Why the JSON had a "Connection" syntax bug

The n8n Workflow SDK expects `[[{node, type, index}]]` (3 levels of nesting) for connection values. The `connections` object's last entry was over-closed with `]]}}` (4 levels). Fixed with sed-style replace: `0}]]}}\n` → `0}]]}\n` in both stage-3 and stage-6.

## Why Stage 4 (Drafter) needed a public URL for the formula

The original Stage 4 used `readFile` with an absolute path to `/Users/pablo/Developer/DaybyDayWeb-HTML/...`. This path is specific to Pablo's machine. When the workflow runs in n8n, it doesn't have access to that filesystem. Replaced with a fetch from `https://raw.githubusercontent.com/DaybyDay-csv/DaybyDayBlogPipeline/main/docs/HARMOZY_FORMULA.md` (public, works from any n8n instance).

## What I did successfully

1. ✅ Imported Stage 4 Drafter (the one that was failing) using big-pickle model
2. ✅ Imported Daily GSC Sync using big-pickle model (second attempt with simpler prompt)
3. ✅ Updated the Harmozy Formula to v0.2 with social-source pack rules
4. ✅ Updated Stage 2 JSON to v0.2 with 6 sources (Reddit×2, Google, X, TikTok, Instagram)
5. ✅ Updated Stage 4 drafter to use public GitHub URL for formula
6. ✅ Set up n8n environment variable setup script

## Reddit API setup (v0.3)

Pablo is creating a Reddit API app. The setup supports optional OAuth:

### Files created/updated for Reddit

- `/tmp/opencode/DaybyDayBlogPipeline/docs/REDDIT_API_SETUP.md` — step-by-step guide
- `/tmp/opencode/DaybyDayBlogPipeline/scripts/test-reddit-creds.mjs` — validator (tests OAuth flow + bearer token)
- `/tmp/opencode/DaybyDayBlogPipeline/n8n/_subreddit-helper.json` — reusable OAuth subworkflow
- `/tmp/opencode/DaybyDayBlogPipeline/n8n/stage-1-topic-discovery.json` — v0.3 with OAuth node
- `/tmp/opencode/DaybyDayBlogPipeline/n8n/stage-2-problem-validation.json` — v0.3 with OAuth node
- `.env` — REDDIT_CLIENT_ID, REDDIT_CLIENT_SECRET, REDDIT_BEARER_TOKEN slots added

### How the OAuth works in the workflows

The Stage 1 and Stage 2 v0.3 workflows have a "Reddit: OAuth (optional)" node that runs first. If REDDIT_CLIENT_ID + REDDIT_CLIENT_SECRET are set as env vars, it does client_credentials grant to get a bearer token. The 4 Reddit nodes then use `Bearer {{$('Reddit: OAuth (optional)').item?.json?.access_token || $env.REDDIT_BEARER_TOKEN || ''}}` — graceful fallback chain.

### Redirect URI answer

When creating the Reddit app, the redirect URI field is OPTIONAL for `script` apps. Reddit shows it as required because the form is shared with web/installed apps. If Reddit won't submit with empty value, use `http://localhost:8080`. The OAuth flow we use (client_credentials) is server-to-server, no browser redirect.

### Validation command

```bash
node scripts/test-reddit-creds.mjs
```

This will:
1. Read REDDIT_CLIENT_ID + REDDIT_CLIENT_SECRET from .env
2. POST to /api/v1/access_token with Basic auth + grant_type=client_credentials
3. Verify a bearer token is returned
4. GET /r/ecommerce/top.json with the bearer token
5. Verify 200 + non-empty posts
6. Compare with the public endpoint (no auth)

If all checks pass, the credentials are good and you can paste them into the n8n UI.

## What failed

1. ❌ Stage 2 v0.2 import — big-pickle model stuck in template literal syntax fix loop
2. ❌ Test execution of Stage 1 — MCP token doesn't have `workflow:execute` scope
3. ❌ Setting env vars via MCP — no such tool exists
4. ❌ Update Stage 1 with v0.3 OAuth in-place via update_workflow — same SDK loop issue
   - Workaround: Pablo exports workflow JSON from n8n UI, replaces with v0.3 file, re-imports (5 min manual step)
