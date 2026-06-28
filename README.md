# hr-ppt

A Claude Code [Agent Skill](https://docs.claude.com/en/docs/claude-code/skills) — a thin scenario wrapper around [`ppt-master`](https://github.com/anthropics/skills) (or your own `ppt-master` install) that locks two presentation profiles instead of doing free design:

- **Academic** — congress / lecture decks (medical & research, AMA citations, figure/table numbering, data-chart heavy)
- **Company** — hr business-blue corporate decks (status reports, performance reviews, project summaries)

It does **not** reimplement the SVG → PPTX pipeline. On invocation it locks one profile's template + narrative mode + visual style + typography/color/citation defaults, then delegates straight into the unmodified `ppt-master` pipeline (Step 1 → Step 7), seeding the Eight Confirmations with the profile's recommended values. Every confirmation gate stays user-editable — the wrapper only changes defaults, never the blocking gates.

## Requirements

- Claude Code with the `ppt-master` skill installed at a path you control
- Update `${PPT_MASTER_DIR}` in `SKILL.md` to point at your local `ppt-master` install

## Install

Drop this folder into your Claude Code skills directory, e.g.:

```
~/.claude/skills/hr-ppt/
```

## Usage

Ask for an academic congress deck or a company report — the skill auto-detects which profile fits, or asks once if genuinely ambiguous. See `SKILL.md` for the full profile tables and pipeline delegation contract.

## License

MIT — see [LICENSE](LICENSE).
