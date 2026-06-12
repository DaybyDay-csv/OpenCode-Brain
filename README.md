# OpenCode-Brain

Persistent, project-keyed memory for every opencode session. Each project
gets its own folder under `brain/` with an Obsidian-style layout:

```
brain/<Project>/
  _index.md         project status, goals, pointers (curated)
  decisions.md      append-only decision log with frontmatter
  log/<YYYY-MM-DD>.md    chronological transcript, one file per day
brain/_unfiled/    anything captured without a project selection
index.jsonl        one line per digest flush
skills/<slug>/     one global-scope skill per project (auto-loaded)
```

## The 10 project slugs (also the valid `#hashtags`)

`#DaybyDay` `#Garett` `#LMDJ` `#Linkedin` `#DaybyDay-Blogpost-System`
`#DaybyDay-Outreacher` `#Ferra` `#Harmozy` `#DaybyDay-Lead-Magnets`
`#Globalthy`

## Session start

Every new opencode session starts with a numbered menu of all 10 projects
plus `new`, `recent`, `unfiled`. The plugin (`~/.config/opencode/plugins/opencode-brain.ts`)
prompts the user via the `question` tool if the first user message has no
hashtag and no project is yet selected for the session.

Selection sticks for the rest of the session; use `/brain open <project>`
or `/brain close` to switch.

## Capturing

- Every 3 user turns (or on `session.idle`) the plugin flushes the buffer
  to `brain/<Project>/log/<YYYY-MM-DD>.md`.
- Decisions are NOT auto-extracted. When the user says
  "OK / agreed / decidid / vamos con", the agent writes a new section to
  `brain/<Project>/decisions.md` with frontmatter
  (`type: decision`, `status: accepted`, `date`, `project`).
- The agent also updates `brain/<Project>/_index.md` when a decision
  changes the project's state or goals.

## Manual commands

```
/brain                 # show the menu
/brain open Ferra      # switch to Ferra
/brain new MyProject   # create a new project folder + skill placeholder
/brain recent          # list recently used projects
/brain status          # current project, turn count, pending decisions
/brain unfiled         # show _unfiled/ contents
/brain close           # exit project (next prompt without hashtag will
                       # trigger the menu again)
```

## State

`~/.config/opencode/brain-state.json` — current session, selected
project, pending buffer. Delete to reset.

## Disabling

`OPENCODE_BRAIN_DISABLE=1` no-ops the plugin without removing the file.
