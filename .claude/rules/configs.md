---
paths:
  - 'base.json'
  - 'bundler.json'
  - 'node.json'
  - 'test/**'
  - 'scripts/validate-configs.mjs'
  - 'package.json'
---

# The presets and their validation

- `base.json`, `bundler.json` and `node.json` are the package's `exports`. A stricter compiler
  option (a new `strict*` flag, say) breaks consumers' builds: prefer additive, opt-in changes,
  and escalate a breaking one or a new export to the maintainer.
- `npm run validate` (`scripts/validate-configs.mjs`) compiles a fixture under `test/<config>/`
  that `extends` each preset (`tsc --noEmit` and `tsc --showConfig`). CI runs it against the
  TypeScript version pinned in `.github/workflows/ci.yml`; locally, install that version with
  `npm install --no-save --no-package-lock typescript@<pin>` first.
- The CI TypeScript pin must satisfy the `typescript` peer range in `package.json`; Renovate bumps
  it (a regex manager in `renovate.json`) and never automerges it.
- This package ships no dependencies and commits no lockfile.
- A release tag must match `version` in `package.json` (`tag-version-match` checks it).
