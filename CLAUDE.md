# tsconfig

Shared, published **TypeScript base configs** for the maintainer's repos: `base.json`,
`bundler.json`, `node.json`.

> **⚠️ ESTE PAQUETE NO SE PUBLICA EN npm, y la frase de arriba decía lo contrario.**
>
> Los consumidores lo instalan como **dependencia de git**, no del registro:
> `"@studio/tsconfig": "git+https://github.com/igonzalezespi-apps/tsconfig.git#v0.0.0"`.
>
> No es un matiz. Comprobado el 2026-08-12: el nombre **`@studio/tsconfig` SÍ existe en npm y es de otra
> persona** — `mantoni`, «The JavaScript Studio», desde 2016. Un `pnpm add @studio/tsconfig` siguiendo la
> línea anterior no habría fallado: habría instalado el paquete de un tercero creyendo que era
> éste. Una falsedad en un contrato que se puede *ejecutar* es peor que una que solo confunde.
>
> Lo que sí es cierto y sigue mandando: **la API pública es real**. Un cambio en lo exportado rompe
> a cada consumidor, y por eso los consumidores lo pinean **por tag**.
 Public (MIT). Consumed as a **git dependency pinned by tag** and referenced with `extends`, so each
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
- **Branch flow: `develop` → `main`.** `develop` is the default branch: work PRs target it and
  land by **squash** — by convention, not by settings (all three merge methods are enabled):
  every PR becomes **one** Conventional Commit whose message is the **PR title**, and that
  title drives the computed changelog/version — so PR titles MUST be valid Conventional
  Commits. Work reaches `main` only through the **promotion PR** `develop` → `main`, which the
  maintainer merges with a **merge commit**; an agent never merges into `main`. PR branches
  update via rebase; the only sanctioned force-push is `--force-with-lease` on your own PR
  branch (never GitHub's "Update branch" button, which puts a merge commit on the branch).
  **One measured exception:** dependency PRs still open against `main`, because the shared
  Renovate preset this repo extends (`renovate-config:config-repo`) pins its base branch there
  (`gh pr list --repo igonzalezespi-apps/tsconfig --state merged --search 'author:app/renovate' --json baseRefName`).
  *(Corrected 2026-09-29. Until then this bullet said «trunk → main, squash-only. PRs target `main`» <!-- flow-claim: allow -->
  and «enforced by repo settings», a month after the move to `develop` on 2026-08-26. Re-measure
  with `gh api repos/igonzalezespi-apps/tsconfig --jq '[.default_branch,.allow_squash_merge,.allow_merge_commit,.allow_rebase_merge]'`
  and `gh pr list --repo igonzalezespi-apps/tsconfig --state merged --limit 10 --json baseRefName,headRefName`.)*
- **No secrets committed** — placeholders only.
- Treat each `*.json` as a stable contract: a stricter compiler option (e.g. a new `strict*`
  flag) is a breaking change for consumers — prefer additive/opt-in changes.

## Enforcement floor

This repo carries the studio's committed enforcement floor:

- **Vendored `bash-guard`** (`scripts/hooks/bash-guard.sh`) — a PreToolUse Bash tripwire
  cabled in `.claude/settings.json`. It denies direct pushes to `main`, history rewrites,
  `--no-verify`, credential dumps, and off-allow-list network egress. It is a best-effort
  guard against agent mistakes, **not** a security boundary, and it fail-opens. Its per-repo
  policy is `scripts/hooks/guard.policy.json` (`develop` → `main`, `agent_may_merge: true`: the
  agent may merge into `develop` under its gates, never into `main`); the vendored core is
  pinned in `scripts/hooks/.vendor.lock` and refreshed/verified with the core-dev
  `/guard-sync` + `/guard-verify`.
  *(Corrected 2026-09-29: this said «(trunk → main, `agent_may_merge: false`)», <!-- flow-claim: allow -->
  while the policy file has said `integration_branch: develop` and `agent_may_merge: true` since
  2026-08-26 — the file was right and this line was not. Re-measure with
  `jq . scripts/hooks/guard.policy.json`.)*
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
