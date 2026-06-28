---
name: hr-ppt
description: >
  Specialized presentation builder for two locked scenarios: academic congress /
  lecture decks (medical / research, AMA citations, data charts) and company-standard
  corporate decks (hr business-blue). A thin specialization of ppt-master — it locks
  the template, narrative mode, visual style, and convention defaults per scenario, then
  runs the full ppt-master pipeline. Use when the user asks for a "学术PPT", "大会幻灯",
  "讲座幻灯", "congress slides", "学术讲座", "公司PPT", "公司汇报", "述职/项目总结幻灯",
  "hr模板PPT", or mentions "hr-ppt". For generic / free-design decks with no scenario
  lock, use ppt-master instead.
---

# HR-PPT — Academic & Company Presentation Builder (hr)

> A **thin specialization** of `ppt-master`. It does **not** reimplement the pipeline. It locks
> a scenario *profile* (template + mode + visual style + conventions + confirmation defaults),
> then runs the unmodified `ppt-master` Step 1 → Step 7 pipeline with those defaults injected.

**Engine root** (`${PPT_MASTER_DIR}`): `C:\Users\Administrator\.claude\skills\ppt-master`
All scripts, references, templates, and workflows referenced below live under that directory.
This skill adds only the profile layer; everything else is ppt-master's.

> [!CAUTION]
> ## Inherited discipline (non-negotiable)
> Every rule in `${PPT_MASTER_DIR}/SKILL.md` **Global Execution Discipline** applies here unchanged —
> serial pipeline, ⛔ BLOCKING Eight Confirmations gate, no sub-agent SVG, sequential page generation,
> per-page `spec_lock.md` re-read, hand-written SVG only. This skill changes **defaults and recommendations**,
> never the gates. The Eight Confirmations are still presented and still BLOCK on user confirmation — the
> profile only pre-fills the *recommended* values the user sees.

---

## Step 0 — Profile Selection (this skill's only added step)

🚧 **GATE**: user invoked this skill (or asked for an academic / company deck).

Pick the profile. **Do not ask if the request already makes it obvious** (e.g. "做个学术讲座" → academic;
"用hr模板做述职" → company; the CLAUDE.md `公司模板` alias → company). Ask one question only when genuinely ambiguous:

> 这份要走 **学术**（大会/讲座·医学研究·AMA 引用·数据图表）还是 **公司**（hr商务蓝·汇报/述职）模板？

Once chosen, announce the locked profile in one line, then proceed to **Pipeline Delegation** below.

---

## Profile A — 学术 / Academic (congress · lecture · medical research)

Locks the following as the **recommended defaults** carried into ppt-master Step 3 + Step 4:

| Slot | Locked default | Notes |
|---|---|---|
| **Template (Step 3)** | `${PPT_MASTER_DIR}/templates/layouts/medical_university` (`kind: layout`) | Inject this path into Step 3 as if the user supplied it → Step 3 dispatches it (structure locked; identity decided in confirmations e–g). |
| **Mode (§d Layer 1)** | `instructional` | Teaching/explaining a topic. Alternate `pyramid` when the deck is a data-review / conclusion-first results talk. |
| **Visual style (§d Layer 2)** | `editorial` | Clean academic hierarchy, serif/sans interplay. Alternates: `data-journalism` (chart-dense), `swiss-minimal` (type-led). |
| **Color (§e)** | medical teal / academic blue family | Default to the layout's medical-blue identity; offer a teal variant (matches the user's NSCLC congress decks). Still a ≥3-candidate confirmation. |
| **Typography (§g)** | CJK 思源黑体/微软雅黑 · Latin Segoe UI/Source Sans; `delivery_purpose: presentation` baseline | Academic lecture = projected; default body baseline 32px unless source is text-dense. |
| **Formula policy (§7)** | `mixed` | Render stats / pharmacokinetic / complex expressions as PNG; keep simple inline as text. |
| **Citations / data** | AMA numbered references; figure & table numbering; source line on every data/chart page | Author into §IX outline and page footers; superscript numbering in body. |
| **`content_divergence`** | follow source closely | Academic facts stay sourced at every level — no invented data, conclusions traceable to the source. |
| **Image usage (§h)** | default `none` / `provided` | Academic decks lean on charts + provided figures; only run AI/web image acquisition if the user asks. |

---

## Profile B — 公司 / Company (hr corporate · 汇报 · 述职 · 项目总结)

| Slot | Locked default | Notes |
|---|---|---|
| **Template (Step 3)** | `${PPT_MASTER_DIR}/templates/decks/company_standard` (`kind: deck`) | The hr standard deck — full replica (identity + structure + middle all locked). Inject this path into Step 3. Same target as the CLAUDE.md `公司模板` alias. |
| **Mode (§d Layer 1)** | `pyramid` | Conclusion-first exec reporting (述职 / 项目总结). Alternate `briefing` for status / 周报 / reference packs. |
| **Visual style (§d Layer 2)** | `swiss-minimal` | Stable, professional, grid-locked — matches the business-blue deck. Alternate `soft-rounded` for training material. |
| **Color (§e)** | locked by deck = business blue `#2661B2` | Deck `kind` locks identity; do not re-poll color unless the user overrides. |
| **Typography (§g)** | CJK 微软雅黑 · Latin Segoe UI; `delivery_purpose` per use (述职=presentation, 文档型汇报=balanced) | — |
| **Voice & tone** | restrained corporate Chinese | Inherited from the deck's identity segment. |
| **Image usage (§h)** | default `none` / `provided` | Corporate decks use brand assets + provided figures; AI imagery off unless asked. |
| **Formula policy (§7)** | `text-only` | Corporate reporting rarely needs rendered formulas. |

> ➕ **Adding more company brands later**: register them as `kind: deck` (or `kind: brand`) packages under
> `${PPT_MASTER_DIR}/templates/decks|brands/`, then add a profile-B variant row here pointing at the new path.
> Same mechanism as the CLAUDE.md template-alias table.

---

## Pipeline Delegation

After Step 0 locks a profile, **load `${PPT_MASTER_DIR}/SKILL.md` and run its full pipeline Step 1 → Step 7 unchanged**, with exactly these injections from the chosen profile:

1. **Step 3 (Template Option)** — treat the profile's **Template path** as an *explicit user-supplied directory path*. This triggers ppt-master's Step 3 dispatch (single-path: read the spec's `kind`, copy into `<project>/templates/`, split bitmaps to `images/`) exactly as if the user had typed the path. No fuzzy matching — the path is concrete.
2. **Step 4 (Strategist / Eight Confirmations)** — present the Eight Confirmations as ppt-master defines, but seed each **recommended** value from the profile table above (mode, visual style, color, typography, formula policy, image usage, conventions). The ⛔ BLOCKING gate is unchanged: the user confirms or edits; confirmed values win and are written verbatim to `design_spec.md` / `spec_lock.md`. For the academic profile, also fold the AMA-citation + figure-numbering conventions into the §IX outline authoring and page-footer plan.
3. **Steps 1, 2, 5, 6, 7** — run exactly as ppt-master specifies. No changes. (Step 5 image acquisition usually skips, since both profiles default image usage to `none`/`provided`.)

Everything else — source conversion, project init, Strategist role definition, Executor SVG rules, quality check, post-processing, export — is ppt-master's, read from `${PPT_MASTER_DIR}/references/…` and `${PPT_MASTER_DIR}/scripts/…` at the points the pipeline calls for them.

> **Windows note**: if a `python3 …` command fails, rerun with `python` (python.org installs ship `python.exe`, not `python3.exe`).
