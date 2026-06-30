# Keep Local hr-ppt Synced With GitHub

GitHub is the durable source of truth for `hr-ppt`:

```text
https://github.com/Linglong-AI/hr-ppt
```

The installed Codex skill copy should match GitHub `main`. Local emergency
fixes are allowed, but they should be pushed back to GitHub before the installed
copy is treated as current.

## Normal Update

If the installed skill folder is a valid Git checkout:

```powershell
git -C "$HOME\.codex\skills\hr-ppt" pull --ff-only origin main
```

Then validate the skill.

## Repair Or Reinstall Update

If the installed skill folder is not a valid Git checkout, or the `.git`
metadata is broken, run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/sync_local_from_github.ps1
```

The script clones GitHub to a temporary directory, backs up the existing
installed copy, then mirrors the GitHub version into the installed location as a
real Git checkout.

## Push-Then-Install Rule

When changing the skill itself:

1. Make the change in a Git checkout.
2. Commit and push to `Linglong-AI/hr-ppt`.
3. Update the installed copy from GitHub.
4. Validate the installed copy.

This avoids the common failure mode where the local installed copy has fixes
that GitHub does not have, or GitHub has newer fixes that the installed copy
does not have.

## Quick Verification

```powershell
git -C "$HOME\.codex\skills\hr-ppt" rev-parse --short HEAD
git -C "$HOME\.codex\skills\hr-ppt" status --short
```

The installed commit should match GitHub `main`, and `status --short` should be
empty except for intentionally ignored runtime files.
