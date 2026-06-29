---
deck_id: company_standard
kind: deck
summary: 企业内部汇报、工作/项目总结、述职与通用商务演示；稳重、专业的商务蓝风格。
canvas_format: ppt169
page_count: 5
primary_color: "#2661B2"
keywords: [商务, 蓝色, 企业, 汇报, 通用]
replication_mode: standard
placeholders:
  01_cover: ["{{TITLE}}", "{{SUBTITLE}}", "{{AUTHOR}}", "{{DATE}}"]
  02_toc: ["{{TOC_ITEM_1_TITLE}}", "{{TOC_ITEM_1_DESC}}", "{{TOC_ITEM_2_TITLE}}", "{{TOC_ITEM_2_DESC}}", "{{TOC_ITEM_3_TITLE}}", "{{TOC_ITEM_3_DESC}}", "{{TOC_ITEM_4_TITLE}}", "{{TOC_ITEM_4_DESC}}"]
  02_chapter: ["{{CHAPTER_NUM}}", "{{CHAPTER_TITLE}}", "{{CHAPTER_DESC}}"]
  03_content: ["{{PAGE_TITLE}}", "{{CONTENT_AREA}}", "{{PAGE_NUM}}"]
  04_ending: ["{{THANK_YOU}}", "{{ENDING_SUBTITLE}}", "{{CONTACT_INFO}}"]
---

# 公司标准模板 (company_standard) — Design Specification

> 由公司既有母版 `公司模板.pptx` 标准化重建而成的全局 deck 模板。适用于企业内部汇报、工作/项目总结、述职及通用商务演示。

## I. Template Overview

- **Use cases**: 企业内部汇报、工作总结、项目汇报、述职、通用商务演示
- **Design tone**: 稳重 · 专业 · 克制 · 商务蓝
- **Theme mode**: 浅色（正文白底）；封面、目录、结束页为深色品牌背景
- **一眼识别**: 商务蓝主色 + 青蓝渐变强调条，封面/结束页统一品牌背景大图，目录左图右列编号，章节页右侧蓝色块配超大序号水印。

## II. Color Scheme

| Role | HEX | 用途 |
|------|-----|------|
| 主蓝 Primary | `#2661B2` | 标题、目录序号圆、章节蓝块、页脚 |
| 深蓝 Deep | `#002B5C` | 深色背景兜底、叠色 |
| 亮青 Cyan | `#38BFD4` | 强调条渐变起点 |
| 强调渐变 Accent | `#38BFD4 → #03ABDA → #2C73BA → #2661B1` | 标题下/章节强调条、封面分隔线（横向线性） |
| 浅蓝 Light | `#DCE6F2` / `#CFDDF2` | 英文副标题、深底辅助文字 |
| 米色 Sand | `#F6EAD6` | 备用点缀色 |
| 正文文字 | `#303C49` / `#333333` | 内容正文 |
| 次级文字 | `#595959` / `#566A85` | 说明、导语 |
| 反白文字 | `#FFFFFF` / `#E8EEF6` | 深色背景上的文字 |

## III. Typography

- **CJK**: `微软雅黑 / Microsoft YaHei`（标题加粗）
- **Latin / 数字**: `Segoe UI`（编号、英文眉标、页码）—— 偏离库默认 `Arial` 栈，故在此声明。
- 字号阶梯（px）：封面主标题 53 · 章节标题 42.67 · 页面标题 32 · 目录条目 22 · 正文 18.67 · 说明 14–15 · 章节序号水印 400。

## IV. Signature Design Elements

- **青蓝线性强调条** `url(#accentGrad)`：用于页面标题下方、章节标题下方、封面分隔线，是该模板最具辨识度的元素。
- **封面/结束页统一品牌背景大图** `cover_bg.jpg` + 左上 `logo_main.png`，正文文字居中于左侧深色区。
- **目录**：左半幅品牌配图（叠 45% 深蓝保证白字可读）+ 右侧蓝色编号圆（01–04）列表。
- **章节页**：右侧整块品牌蓝 `#2661B2` + 浅蓝 `#5A8AD4` 超大序号水印 + 英文 `PART NN · SECTION` 眉标。
- **正文页脚**：右下角品牌蓝直角三角 + 反白页码。

## V. Page Roster

| File | Role | 描述 |
|------|------|------|
| `01_cover.svg` | cover | 封面：品牌背景大图 + 左上 Logo + 居中主/副标题 + 汇报人/日期 |
| `02_toc.svg` | toc | 目录：左图右列，4 个蓝色编号圆条目（标题+说明） |
| `02_chapter.svg` | chapter | 章节扉页：右侧蓝块 + 超大序号水印 + 眉标 + 章节标题 + 导语 |
| `03_content.svg` | content | 正文：页面标题 + 渐变强调条 + 右上 Logo + 自由内容区 + 页脚页码 |
| `04_ending.svg` | ending | 结束页：同封面品牌背景 + 致谢中英文 + 汇报信息 |

## VI. Assets

| File | 用途 |
|------|------|
| `cover_bg.jpg` | 封面 / 结束页全屏品牌背景图 |
| `toc_side.jpg` | 目录页左半幅品牌配图 |
| `logo_main.png` | 封面 / 目录 / 结束页左上主 Logo |
| `logo_sm.png` | 章节页左上小 Logo |
| `logo_corner.png` | 正文页右上角 Logo |
