# hr-ppt

Self-contained presentation skill for two locked scenarios:

- **Academic**: congress, lecture, medical/research, citation-aware, data-heavy decks.
- **Company**: HR business-blue corporate reports, project summaries, performance reviews, and internal briefings.

This repository includes the complete embedded ppt-master pipeline: scripts,
references, templates, workflows, dependency list, and environment example.
Standalone use needs no separate `ppt-master` install and no external path
configuration.

## Install

Place this folder in your skills directory, for example:

```text
~/.claude/skills/hr-ppt/
```

## Contents

- `SKILL.md`: HR-PPT entry point and profile selection.
- `references/ppt-master-core.md`: embedded core pipeline instructions.
- `scripts/`: source conversion, project management, image, SVG, and PPTX tools.
- `templates/`: layouts, decks, chart templates, icons, and design specs.
- `workflows/`: standalone workflows such as beautify, template-fill, live preview, and chart verification.
- `requirements.txt`: Python dependencies used by the embedded tools.
- `.env.example`: optional provider and runtime configuration.

## Usage

Ask for an academic deck or a company report deck. The skill chooses the profile
when obvious, asks once when ambiguous, then runs the embedded pipeline using the
bundled resources.

## License

MIT - see [LICENSE](LICENSE).
