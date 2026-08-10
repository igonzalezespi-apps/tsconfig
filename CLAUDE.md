# tsconfig

Shared, published **TypeScript base configs** for the maintainer's repos: `base.json`,
`bundler.json`, `node.json`. Public (MIT). Consumed as an npm dependency (`extends`), so each
config is a public API — a compiler-option change affects every consumer's build.

## Rules

- **Public repo — never name a private project.** Not in configs, docs, comments, commit
  messages, or CI. A local `pre-commit` guard (`.githooks/pre-commit`) enforces this against a
  private denylist; enable it per clone with `git config core.hooksPath .githooks` (it is a
  no-op where the denylist is absent, e.g. a fork). Not wired via a package `prepare` script
  on purpose — that would run in consumers' installs.
- **Language / Idioma** — Reply to the user (Ivan) in **Spanish**; he reads Spanish and this
  holds in every repo and session. Author the OpenSpec docs the user reads — `proposal.md`,
  `design.md`, `tasks.md` — in **Spanish** too. Everything else stays **English**: source
  code, comments, identifiers, this contract file's own text, skills/SKILL.md, agent prompts,
  and OpenSpec **spec deltas** (`specs/**/spec.md`, which keep their `SHALL` / `WHEN`/`THEN`
  RFC2119 keyword format).
- **Conventional Commits** — `type(scope): description` (`feat/fix/chore/docs/ci`).
- **Branch flow: trunk → main, squash-only.** PRs target `main` and land by **squash** (enforced
  by repo settings): every PR becomes **one** Conventional Commit whose message is the **PR
  title**, and that title drives the computed changelog/version — so PR titles MUST be valid
  Conventional Commits. PR branches update via rebase; the only sanctioned force-push is
  `--force-with-lease` on your own PR branch (never GitHub's "Update branch" button, which
  puts a merge commit on the branch).
- **No secrets committed** — placeholders only.
- Treat each `*.json` as a stable contract: a stricter compiler option (e.g. a new `strict*`
  flag) is a breaking change for consumers — prefer additive/opt-in changes.

## Enforcement floor

This repo carries the studio's committed enforcement floor:

- **Vendored `bash-guard`** (`scripts/hooks/bash-guard.sh`) — a PreToolUse Bash tripwire
  cabled in `.claude/settings.json`. It denies direct pushes to `main`, history rewrites,
  `--no-verify`, credential dumps, and off-allow-list network egress. It is a best-effort
  guard against agent mistakes, **not** a security boundary, and it fail-opens. Its per-repo
  policy is `scripts/hooks/guard.policy.json` (trunk → main, `agent_may_merge: false`); the
  vendored core is pinned in `scripts/hooks/.vendor.lock` and refreshed/verified with the
  core-dev `/guard-sync` + `/guard-verify`.
- **Local git hooks** (`.githooks/pre-commit`, `.githooks/commit-msg`) — cabled per clone with
  `git config core.hooksPath .githooks`; they are the only layer that stops a *human* commit.
- **CI reports, it does not block.** There are no required status checks, so a red run does not
  prevent a merge. And **nothing is enforced server-side**: branch protection and rulesets are
  **deliberately not enabled** on this repo (verified:
  `gh api repos/<owner>/<repo>/branches/main/protection` → `404`, `.../rulesets` → `[]`) — an
  explicit standing decision, not an oversight. Enabling them is what would make a push to
  `main` or a merge over a red check technically impossible instead of merely forbidden.
- **Plugins** (`.claude/settings.json` → `enabledPlugins`): `core-dev`, `studio-policy`,
  `stack-node`, from the maintainer's `ivan` marketplace. Declaring them does not install
  them — run `./bootstrap.sh` once per clone/machine (it installs the plugins, wires the
  pre-commit guard, and verifies the vendored guard when the tooling is reachable).
- On a fork all of this degrades to harmless no-ops (no denylist, no marketplace access): the
  configs still compile and the package still works.

## Reserved to Ivan (escalate, do not decide)

Breaking a public config API (a stricter `strict*` flag or any compiler-option change that
alters a consumer's build) · adding a new published export · repo visibility · anything that
edits this contract. The company-wide layer of this contract is injected by the
`studio-policy` plugin, so this file stays repo-specific and self-contained.
