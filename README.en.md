<div align="center">

# 🐣 From Novice to Pro

**A computer basics course for absolute beginners: proxy setup + development environment**

[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Chapters](https://img.shields.io/badge/chapters-22-blue)](docs/)

**📖 Read online**: https://yanwaiyue-name.github.io/xiaobai-to-dalao/
**中文**: [README.md](README.md)

</div>

---

## The premise

Most tutorials assume you already know things. This one assumes you know **nothing**.

Every chapter answers three questions: **what to install, how to install it, how to confirm it worked.**

## Structure

```
docs/
├── 00 前言 — how to use this repo
├── 01 科学上网篇 (8 chapters) — VPN concepts, clients, troubleshooting, safety
├── 02 环境部署篇 (9 chapters) — Git, Python, Node.js, Java, VS Code, Docker, MySQL, troubleshooting
└── 99 进阶篇 (in progress)
```

22 chapters total. Content is in Simplified Chinese.

## What makes a chapter usable

Every chapter follows a fixed structure:

1. **What this solves** — one paragraph, what you can do after finishing
2. **Prerequisites** — what you need to know first
3. **Numbered steps** — each with a copy-pasteable command
4. **✅ Verification** — how to confirm you didn't waste your time
5. **Common pitfalls** — a table of symptom → cause and fix
6. **Navigation** — prev / index / next, both at top and bottom

## The site is generated, not hand-written

`scripts/build-site.ps1` renders all 22 Markdown chapters into a static site with **zero external dependencies** — no pandoc, no node packages, no third-party modules. Just PowerShell.

Key properties:

- **Byte-identical output across PowerShell 5.1 and PS 7** — verified by SHA-256 on all 22 files
- **Zero broken internal links** — CI validates every `href` after each build
- **Duplicate anchor IDs auto-suffixed** — two "✅ 验证" headings on one page no longer collide
- **Code block language auto-detection** — 94% of fences get syntax highlighting even when the source has no language tag

## Automated checks

| Workflow | What it does |
|---|---|
| 链接每周体检 | Weekly lychee link check across all docs |
| Build docs site | Builds the site on every push, validates internal links, deploys to Pages |
| 版本时效检查 | Weekly: compares version numbers in the docs against upstream releases |

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md). Every chapter must follow the structure above.

## Disclaimer

Technical content ages. If a command no longer works or a link is dead, please open an issue.
