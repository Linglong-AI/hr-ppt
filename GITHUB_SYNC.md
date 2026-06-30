# Keep hr-ppt Synced Across GitHub, Codex, and Claude

GitHub is the durable source of truth for `hr-ppt`:

```text
https://github.com/Linglong-AI/hr-ppt
```

The installed Codex and Claude skill copies should both match GitHub `main`.
Local emergency fixes are allowed, but they should be pushed back to GitHub
before any installed copy is treated as current.

## Installed Locations

```text
Codex:  C:\Users\Administrator\.codex\skills\hr-ppt
Claude: C:\Users\Administrator\.claude\skills\hr-ppt
GitHub: https://github.com/Linglong-AI/hr-ppt
```

## Normal Update

For the everyday "make everything consistent" path, run:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\skills\hr-ppt\scripts\sync_everywhere.ps1"
```

This handles the simple cases:

- GitHub changed: update both Codex and Claude from GitHub.
- Codex changed: commit/push Codex, then update Claude.
- Claude changed: commit/push Claude, then update Codex.
- A local copy is missing or has broken `.git` metadata: repair it from GitHub.

If Codex and Claude both have different uncommitted changes, the script stops
and asks for a manual decision instead of guessing.

To only update installed copies from GitHub without promoting local changes:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\skills\hr-ppt\scripts\sync_local_from_github.ps1"
```

To update only one side:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\skills\hr-ppt\scripts\sync_local_from_github.ps1" -Target codex
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\skills\hr-ppt\scripts\sync_local_from_github.ps1" -Target claude
```

## Manual Fast-Forward Alternative

If both installed folders are already valid Git checkouts:

```powershell
git -C "$HOME\.codex\skills\hr-ppt" pull --ff-only origin main
git -C "$HOME\.claude\skills\hr-ppt" pull --ff-only origin main
```

Then validate both copies.

## Push-Then-Install Rule

When changing the skill itself:

1. Make the change in a Git checkout.
2. Commit and push to `Linglong-AI/hr-ppt`.
3. Update the Codex and Claude installed copies from GitHub.
4. Validate both installed copies.

This avoids the common failure mode where one local installed copy has fixes
that GitHub does not have, or GitHub has newer fixes that one local copy does
not have.

## Quick Verification

```powershell
git -C "$HOME\.codex\skills\hr-ppt" rev-parse --short HEAD
git -C "$HOME\.claude\skills\hr-ppt" rev-parse --short HEAD
git -C "$HOME\.codex\skills\hr-ppt" status --short
git -C "$HOME\.claude\skills\hr-ppt" status --short
```

Both installed commits should match GitHub `main`, and `status --short` should
be empty except for intentionally ignored runtime files.
