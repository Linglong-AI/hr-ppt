---
name: hr-ppt
description: >
  Self-contained presentation builder for two locked scenarios: academic congress /
  lecture decks (medical or research, AMA citations, figure/table numbering, data
  charts) and HR corporate decks (business-blue company reports, project summaries,
  performance reviews, internal briefings). Includes the full embedded ppt-master
  SVG-to-PPTX pipeline, scripts, templates, workflows, and references; no external
  ppt-master install or path configuration is required. Use when the user asks for
  academic slides, congress slides, lecture slides, medical/research decks,
  company PPT, corporate report, project summary deck, HR template PPT, or mentions
  hr-ppt.
---

# HR-PPT

HR-PPT is a self-contained presentation skill. It embeds the complete ppt-master
pipeline inside this skill folder, then adds two opinionated profiles on top:

- Academic: congress, lecture, medical, and research decks.
- Company: HR business-blue corporate reports and internal summaries.

Do not require, search for, or delegate to an external `ppt-master` installation.
All core instructions and resources live in this skill folder.

## Embedded Core

Set `SKILL_DIR` to the directory containing this `SKILL.md`.

Before running the generation pipeline, read `references/ppt-master-core.md`
completely. That file is the embedded core pipeline. Treat every path in it as
relative to this HR-PPT skill root:

- `scripts/` contains the executable pipeline tools.
- `references/` contains supporting instruction files.
- `templates/` contains layouts, decks, chart templates, icons, and specs.
- `workflows/` contains standalone or opt-in workflows such as beautify,
  template-fill, visual review, chart verification, and live preview.
- `requirements.txt` and `.env.example` are bundled in this repository.

The embedded core's Global Execution Discipline remains mandatory: serial
pipeline, blocking Eight Confirmations gate, no speculative execution, no
sub-agent SVG generation, sequential page generation, per-page `spec_lock.md`
re-read, and hand-written SVG pages.

## Step 0: Profile Selection

Select one profile before entering the embedded core pipeline. Do not ask if the
request already makes the profile obvious. Ask one concise question only when it
is genuinely ambiguous:

> Should this use the Academic profile or the Company profile?

After choosing, announce the locked profile in one line, then proceed to the
embedded core pipeline with the profile injections below.

## Profile A: Academic

Use for congress talks, lectures, medical research decks, journal-club style
presentations, and data-heavy scientific narratives.

| Slot | Locked default | Notes |
| --- | --- | --- |
| Template | `${SKILL_DIR}/templates/layouts/medical_university` (`kind: layout`) | Inject as an explicit Step 3 template directory path. |
| Mode | `instructional` | Use `pyramid` for conclusion-first results reviews. |
| Visual style | `editorial` | Use `data-journalism` for chart-dense decks or `swiss-minimal` for type-led decks. |
| Color | medical teal / academic blue | Default to the layout identity; offer teal when it fits oncology or clinical decks. |
| Typography | CJK Microsoft YaHei or Source Han Sans; Latin Segoe UI or Source Sans | Projected lecture baseline; avoid tiny body text. |
| Formula policy | `mixed` | Render complex equations as PNG; keep simple inline formulas as text. |
| Citation policy | AMA numbered citations | Add figure/table numbering and a source line on every data/chart page. |
| Content divergence | follow source closely | No invented data; conclusions must trace to source material. |
| Image usage | `none` or `provided` | Prefer charts and supplied figures; search or generate images only when requested. |

## Profile B: Company

Use for HR business-blue company reports, internal briefings, project summaries,
performance reviews, work reports, and management readouts.

| Slot | Locked default | Notes |
| --- | --- | --- |
| Template | `${SKILL_DIR}/templates/decks/company_standard` (`kind: deck`) | Inject as an explicit Step 3 template directory path. |
| Mode | `pyramid` | Use `briefing` for status reports, weekly reports, or reference packs. |
| Visual style | `swiss-minimal` | Stable grid, quiet hierarchy, professional report feel. |
| Color | business blue `#2661B2` | Locked by the deck unless the user explicitly overrides. |
| Typography | CJK Microsoft YaHei; Latin Segoe UI | Match delivery purpose: presentation, document-style report, or balanced. |
| Voice | restrained corporate Chinese | Keep wording concise and decision-oriented. |
| Image usage | `none` or `provided` | Prefer brand assets and supplied figures; AI imagery is off unless requested. |
| Formula policy | `text-only` | Corporate reporting usually does not need rendered formulas. |

## Pipeline Execution

After Step 0, run the embedded core pipeline from
`references/ppt-master-core.md` unchanged, with these injections:

1. Step 3 Template Option: treat the selected profile's template path as an
   explicit user-supplied directory path. Read the template `design_spec.md`,
   dispatch by `kind`, copy the template files into the project, and split
   bitmap assets into `images/` exactly as the embedded core specifies.
2. Step 4 Strategist / Eight Confirmations: present the embedded core's Eight
   Confirmations, but seed recommended values from the selected profile. The
   confirmation gate remains blocking; confirmed user edits always win and must
   be written into `design_spec.md` / `spec_lock.md`.
3. Steps 1, 2, 5, 6, 7, post-processing, export, and all standalone workflows:
   follow the embedded core instructions and use only the bundled resources in
   this repository.

When adding more company brands or academic templates later, register them under
this repository's `templates/decks/`, `templates/layouts/`, or
`templates/brands/`, then add a new profile row here pointing to the local path.

## Windows Note

If a `python3 ...` command fails on Windows, rerun the same command with
`python ...`.
