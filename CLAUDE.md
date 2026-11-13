# tsconfig

Shared **TypeScript base configs** (`base.json`, `bundler.json`, `node.json`) for the maintainer's
repos. Public (MIT). Consumers install it as a git dependency pinned by tag
(`github:igonzalezespi-apps/tsconfig#vX.Y.Z`) and reference it with `extends`.

## Rules

- **This repo is public: nothing names a private project** — not configs, docs, comments,
  commits, PRs, issues or comments on them. The `.githooks/` hooks check files and commit
  messages against a private list kept on the maintainer's machine (fail closed there, no-op on
  a fork). Enable them per clone: `git config core.hooksPath .githooks`. They are deliberately
  not wired through a package `prepare` script: that would run in consumers' installs.
- **Not published to npm.** The npm name `@studio/tsconfig` belongs to an unrelated third party:
  never install it from the registry.
- **Each config is a public API.** A compiler-option change alters every consumer's build:
  prefer additive, opt-in changes. Details in `.claude/rules/configs.md`.
- **Language:** reply to the maintainer in Spanish; code, comments and this file stay English.

## Flow

- New worktree from `origin/develop`; PR into `develop`, landed by **squash**, so the PR title
  is the commit and must be a Conventional Commit (it drives the changelog).
- When its checks are green you merge it yourself:
  `gh pr merge <n> --squash --match-head-commit <sha>`. If the change is delicate, first get a
  second read with `/code-review` in a clean context.
- `main` and releases belong to the maintainer: while `develop` exists, the `develop` → `main`
  promotion is theirs (merge commit), and a release tag must match `version` in `package.json`.
- What to ask the maintainer and what you decide comes from the machine's instructions; it is
  not repeated here.

## Commands

```bash
# the package ships no deps and no lockfile; use the TypeScript pin from .github/workflows/ci.yml
npm install --no-save --no-package-lock typescript@<pin>
npm run validate   # compiles a fixture under test/<config>/ against each preset
```

## Where things live

- Presets: `base.json`, `bundler.json`, `node.json` (the package `exports`); fixtures: `test/`;
  validator: `scripts/validate-configs.mjs`.
- Local hooks: `.githooks/` (gitleaks + private-name check). CI: `.github/workflows/` —
  `ci.yml` (validate presets), `hygiene.yml` (gitleaks over history, CLAUDE.md ≤ 6 KB).
