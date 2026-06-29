---
deck_id: hengrui_standard
kind: deck
summary: Hengrui / 恒瑞 business-blue corporate deck template for internal reports, project summaries, performance reviews, and company-standard presentations.
canvas_format: ppt169
page_count: 5
primary_color: "#2661B2"
keywords: [Hengrui, 恒瑞, HR, business blue, company report, corporate deck, internal briefing]
replication_mode: standard
placeholders:
  01_cover: ["{{TITLE}}", "{{SUBTITLE}}", "{{AUTHOR}}", "{{DATE}}"]
  02_toc: ["{{TOC_ITEM_1_TITLE}}", "{{TOC_ITEM_1_DESC}}", "{{TOC_ITEM_2_TITLE}}", "{{TOC_ITEM_2_DESC}}", "{{TOC_ITEM_3_TITLE}}", "{{TOC_ITEM_3_DESC}}", "{{TOC_ITEM_4_TITLE}}", "{{TOC_ITEM_4_DESC}}"]
  02_chapter: ["{{CHAPTER_NUM}}", "{{CHAPTER_TITLE}}", "{{CHAPTER_DESC}}"]
  03_content: ["{{PAGE_TITLE}}", "{{CONTENT_AREA}}", "{{PAGE_NUM}}"]
  04_ending: ["{{THANK_YOU}}", "{{ENDING_SUBTITLE}}", "{{CONTACT_INFO}}"]
---

# Hengrui / 恒瑞 Standard Corporate Template

This is the preserved Hengrui company template. It is a full `deck` template:
identity, page structure, core assets, and page roster are locked unless the user
explicitly asks to change them.

## I. Template Overview

- **Use cases**: internal company reports, project summaries, performance reviews,
  work reports, leadership briefings, and general corporate presentations.
- **Design tone**: restrained, professional, stable, business-blue.
- **Theme mode**: light body pages with dark blue brand cover, TOC, chapter, and
  ending pages.
- **Recognition cues**: Hengrui logo, blue corporate palette, gradient accent
  rule, full-bleed brand background on cover/ending pages, TOC image panel, and
  blue page-number corner on content pages.

## II. Color Scheme

| Role | HEX | Usage |
| --- | --- | --- |
| Primary blue | `#2661B2` | Titles, chapter block, TOC numbers, footer marker |
| Deep blue | `#002B5C` | Cover/ending overlay, dark background support |
| Cyan accent | `#38BFD4` | Gradient accent rule start |
| Accent gradient | `#38BFD4 -> #03ABDA -> #2C73BA -> #2661B1` | Title rules and section accents |
| Light blue | `#DCE6F2` / `#CFDDF2` | Subtitles and secondary reversed text |
| Sand | `#F6EAD6` | Optional warm detail color |
| Body text | `#303C49` / `#333333` | Main content |
| Secondary text | `#595959` / `#566A85` | Captions and explanatory text |
| Reversed text | `#FFFFFF` / `#E8EEF6` | Text on dark blue backgrounds |

## III. Typography

- **CJK**: Microsoft YaHei, bold for titles.
- **Latin / numbers**: Segoe UI.
- **Size ladder**: cover title 53 px; chapter title 42.67 px; page title 32 px;
  TOC item title 22 px; body 18.67 px; captions 14-15 px.

## IV. Signature Design Elements

- Blue linear accent rule under page and chapter titles.
- Hengrui logo on cover, TOC, chapter, content, and ending pages.
- Cover and ending use `cover_bg.jpg` as the full-page brand background.
- TOC uses `toc_side.jpg` on the left and numbered blue entries on the right.
- Chapter page uses a large right-side blue block and oversized section number.
- Content page uses a clean white canvas, upper-right logo, and blue page-number
  corner.

## V. Page Roster

| File | Role | Description |
| --- | --- | --- |
| `01_cover.svg` | cover | Brand background, Hengrui logo, centered title, subtitle, author, date |
| `02_toc.svg` | toc | Left brand image panel, right 4-item numbered agenda |
| `02_chapter.svg` | chapter | Right-side blue block, oversized chapter number, title and guide text |
| `03_content.svg` | content | Page title, accent rule, upper-right logo, free content area, footer page number |
| `04_ending.svg` | ending | Brand background, closing text, report/contact information |

## VI. Assets

| File | Usage |
| --- | --- |
| `cover_bg.jpg` | Cover and ending page full background |
| `toc_side.jpg` | TOC left-side brand image |
| `logo_main.png` | Cover, TOC, and ending Hengrui logo |
| `logo_sm.png` | Chapter page Hengrui logo |
| `logo_corner.png` | Content page upper-right Hengrui logo |

## VII. Execution Rules

- Keep this template as the default Company profile template in HR-PPT.
- Do not rename this template back to a generic company template when the user
  asks for 恒瑞, Hengrui, HR, 公司模板, or hr模板.
- Treat the logo and brand image assets as locked identity assets unless the user
  explicitly supplies replacements.
