# Local HR Overlay Patches

This file lists the downstream behavior that must survive every upstream
`ppt-master` intake.

## Protected Behavior

| Area | Rule |
| --- | --- |
| Self-contained skill | `hr-ppt` must not require an external `ppt-master` installation or path configuration. |
| Scope boundary | Generic free-design decks with no Academic or Company scenario lock should route to a generic ppt-master / presentation workflow unless the user explicitly asks for hr-ppt. |
| Profile selection | `SKILL.md` chooses Academic or Company / Hengrui before entering the embedded core pipeline. |
| Academic profile | Academic decks keep the medical university layout, AMA citation policy, figure/table numbering, and evidence-aware defaults. |
| Company profile | Company decks keep the Hengrui / HR business-blue deck template and restrained corporate report voice. |
| Company aliases | Company template aliases should resolve to the Company / Hengrui profile. |
| Company template | `templates/decks/hengrui_standard/` is a local downstream asset and must never be overwritten by automated upstream sync. |
| HTML Confirm UI | Step 4 uses the HTML Confirm UI by default. Chat-only confirmation is allowed only when the user explicitly opts out or the page launch is verified to have failed. |
| Confirmation artifacts | The workflow must create `confirm_ui/recommendations.json`, wait for the page confirmation, and read `confirm_ui/result.json` before generation. |
| Body-slide count | A request for `N` body pages/slides means cover + `N` body slides + ending page by default for Company / Hengrui decks. |
| Codex Desktop service safety | Long-running local services must verify the reachable URL before reporting success. Bare daemon launches that can be misread as success are not enough. |
| Embedded paths | The embedded core resolves `scripts/`, `references/`, `templates/`, and `workflows/` relative to the `hr-ppt` skill root. |
| Three-way local sync | GitHub is the durable source of truth; both Codex and Claude installed copies must sync from GitHub `main`. |

## Protected Paths

Automated upstream sync must not overwrite these paths:

```text
SKILL.md
README.md
LOCAL_PATCHES.md
UPSTREAM_PPT_MASTER.md
workflows/sync-ppt-master.md
GITHUB_SYNC.md
scripts/sync_from_ppt_master.ps1
scripts/sync_local_from_github.ps1
templates/decks/hengrui_standard/**
```

## Manual-Review Paths

These paths may contain useful upstream changes, but they also touch local
workflow behavior. Stage them and merge intentionally:

```text
references/ppt-master-core.md
references/strategist.md
workflows/live-preview.md
scripts/confirm_ui/**
scripts/config.py
scripts/server_common.py
requirements.txt
.env.example
.gitignore
templates/decks/**
templates/layouts/medical_university/**
```

The protected path list wins over the manual-review list.

## Conflict Rules

When upstream and local overlay conflict:

1. Preserve the local HR rule by default.
2. Extract the useful upstream idea into an HR-aware rewrite.
3. Prefer additive notes or small local patches over replacing whole files.
4. Record rejected or rewritten upstream changes in `UPSTREAM_PPT_MASTER.md`.

## Minimum Regression Checklist

Run these checks after every upstream intake:

1. Validate Python syntax for touched scripts.
2. Confirm `scripts/confirm_ui/server.py` still supports the blocking HTML
   confirmation path.
3. Confirm a bare daemon launch cannot be mistaken for a successful Codex
   Desktop page open; the URL must be reachable.
4. Confirm Company / Hengrui requests still interpret `N` as body-slide count:
   cover + `N` body slides + ending page.
5. Confirm the Hengrui standard template still contains its SVG layouts,
   logos, background assets, and `design_spec.md`.
6. Confirm the embedded core still resolves paths inside this skill folder.
7. Confirm Codex and Claude installed copies point to the same GitHub commit.

## Release Rule

If the sync was performed in a source repository, update both the Codex and
Claude skills directories only after the regression checklist passes. If the
sync was performed directly in an installed copy, mirror the same accepted
changes back to the source repository when available, then update the other
installed copy from GitHub.
