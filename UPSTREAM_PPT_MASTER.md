# Upstream ppt-master Tracking

This file records how `hr-ppt` selectively absorbs useful changes from
`ppt-master` without losing the HR overlay.

## Current Baseline

| Field | Value |
| --- | --- |
| Downstream package | `hr-ppt` |
| Current working copy | GitHub source repository plus installed Codex skill copy |
| Upstream project | `ppt-master` |
| Embedded upstream commit/tag | Not recorded in this installed copy |
| Tracking file created | 2026-06-30 |
| Sync policy | Stage, review, then apply. Never blind-overwrite. |

For local-install synchronization with GitHub, see `GITHUB_SYNC.md`.

On the next real upstream sync, replace `Not recorded in this installed copy`
with the exact upstream commit or tag reviewed.

## Layer Model

`hr-ppt` is maintained as a downstream distribution with a local overlay:

1. Upstream Core: generic `ppt-master` scripts, references, workflows,
   templates, validators, conversion tools, and export tools.
2. HR Overlay: HR-specific profiles, company template defaults, personal
   workflow rules, and Codex Desktop launch safeguards.
3. Installed Copy: the active folder under the Codex skills directory. This may
   be edited for local use, but durable changes should also be mirrored back to
   the source repository when available.

## Sync Branch Rule

When working in a Git repository, create a dedicated branch for every upstream
intake:

```powershell
git switch -c sync/ppt-master-YYYYMMDD
```

When working only in an installed copy, use the staging directory created by
`scripts/sync_from_ppt_master.ps1` and do not treat that copy as upstream truth.

## Change Classes

| Class | Default action | Examples |
| --- | --- | --- |
| Auto candidate | May be applied by the helper script with `-Apply` after review of the manifest. | Generic bug fixes in converters, SVG/PPTX exporters, image utilities, chart SVGs, icon assets, source parsers, validators. |
| Manual review | Stage only. Merge intentionally by reading the upstream and downstream versions. | `references/ppt-master-core.md`, `references/strategist.md`, `workflows/live-preview.md`, `scripts/confirm_ui/`, runtime config, requirements, template indices. |
| Protected overlay | Never overwritten by automated sync. If upstream has a useful idea, rewrite it as an HR-aware patch. | `SKILL.md`, HR profile rules, `templates/decks/hengrui_standard/`, HTML Confirm UI defaults, body-slide count rule, local sync docs. |

## Intake Procedure

1. Identify the upstream `ppt-master` commit or tag.
2. Run the staging helper:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/sync_from_ppt_master.ps1 -UpstreamPath C:\path\to\ppt-master
   ```

3. Read `_sync/.../sync_report.md` and `_sync/.../sync_manifest.csv`.
4. Apply low-risk auto candidates only after confirming the manifest:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/sync_from_ppt_master.ps1 -UpstreamPath C:\path\to\ppt-master -Apply
   ```

5. Manually merge review candidates. Preserve HR-specific overrides.
6. Never auto-apply protected overlay files.
7. Update this file's baseline and sync log.
8. Run the regression checklist in `LOCAL_PATCHES.md`.

## Sync Log

| Date | Upstream commit/tag | Result | Notes |
| --- | --- | --- | --- |
| 2026-06-30 | Not recorded | Tracking initialized | Added downstream sync policy for the installed `hr-ppt` copy. |

## Review Notes

Use this table for future upstream decisions.

| Date | Upstream change | Decision | Reason |
| --- | --- | --- | --- |
| 2026-06-30 | Bootstrap tracking files | Accepted | Defines safe upstream intake boundaries for `hr-ppt`. |
