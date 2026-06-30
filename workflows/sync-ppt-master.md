# Sync ppt-master Into hr-ppt

Use this workflow when `ppt-master` has changed and `hr-ppt` should absorb only
the useful upstream parts.

## Boundary

`hr-ppt` is not a mirror of `ppt-master`. It is a downstream distribution with a
protected HR overlay. Upstream changes are candidates, not commands.

## Preferred Place To Work

Work in the source Git repository when it is available. The installed Codex
skill copy can be used for local emergency fixes, but durable syncs should be
committed in the repository and then installed.

## Steps

1. Confirm the upstream `ppt-master` checkout and record its commit or tag.
2. In the `hr-ppt` source repository, create a sync branch:

   ```powershell
   git switch -c sync/ppt-master-YYYYMMDD
   ```

3. Generate a staged comparison:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/sync_from_ppt_master.ps1 -UpstreamPath C:\path\to\ppt-master
   ```

4. Open the generated report:

   ```text
   _sync/<timestamp>/sync_report.md
   _sync/<timestamp>/sync_manifest.csv
   ```

5. Apply auto candidates only after reading the report:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/sync_from_ppt_master.ps1 -UpstreamPath C:\path\to\ppt-master -Apply
   ```

6. Manually review staged files under `review/`. Merge only the parts that fit
   the HR overlay.
7. Do not apply staged files under `protected/`. If a protected file contains a
   useful upstream idea, rewrite that idea locally.
8. Update `UPSTREAM_PPT_MASTER.md` with the upstream commit, accepted changes,
   rejected changes, and any rewrites.
9. Run the regression checklist in `LOCAL_PATCHES.md`.
10. Commit, push, and reinstall the skill copy.

## What The Helper Script Does

The helper script compares the upstream checkout with this skill folder and
classifies changed files:

- `auto`: low-risk generic files that can be copied with `-Apply`.
- `review`: staged for human merge only.
- `protected`: staged for visibility only; never copied automatically.

By default it writes only `_sync/<timestamp>/...` and does not change the skill
files.

## Practical Rule

Accept upstream fixes that improve the embedded core. Keep local rules that make
`hr-ppt` different from `ppt-master`.
