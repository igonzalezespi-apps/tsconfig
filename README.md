# @studio/tsconfig

The studio's shared **TypeScript base configs**, consumed by **git reference**
(the `renovate-config` pattern — no npm publishing, no tokens). One package at
the repo root, three variants.

## Variants

| Export | Variant | Module / resolution | Extra lib |
| --- | --- | --- | --- |
| `@studio/tsconfig/base.json` | `base` | _(none — variant-neutral strict core)_ | `ES2022` |
| `@studio/tsconfig/node.json` | `node` | `NodeNext` / `NodeNext` | `ES2022` |
| `@studio/tsconfig/bundler.json` | `bundler` | `ESNext` / `Bundler` + `verbatimModuleSyntax` | `ES2022`, `DOM`, `DOM.Iterable` |

`base` carries the agreed strict flags and is module-resolution-agnostic: extend
`node` or `bundler` rather than `base` directly in a real project. Pick:

- **`node`** — backend services, CLIs, libraries that run on Node (`NodeNext`
  resolution, `esModuleInterop` for CJS interop).
- **`bundler`** — anything that goes through a bundler (Next.js, Expo / RN-Web,
  Vite). Adds `Bundler` resolution, `verbatimModuleSyntax` (pairs with the
  studio ESLint `consistent-type-imports` rule), and DOM libs.

### Strict flags in `base`

```jsonc
"strict": true,
"noUncheckedIndexedAccess": true,
"exactOptionalPropertyTypes": true,
"useUnknownInCatchVariables": true,
"noImplicitOverride": true,
"noPropertyAccessFromIndexSignature": true,
"noFallthroughCasesInSwitch": true
```

`base` also sets `declaration`, `declarationMap`, `sourceMap`, `skipLibCheck`,
`resolveJsonModule`, `esModuleInterop`, `forceConsistentCasingInFileNames`, and
`noEmit: true`. Override `noEmit` in any package that actually emits.

## Consume it

This repo is **not published to npm**. Depend on it by git tag:

```jsonc
// package.json
{
  "devDependencies": {
    "@studio/tsconfig": "github:igonzalezespi/tsconfig#v0.1.0"
  }
}
```

Then extend the variant you want:

```jsonc
// tsconfig.json — a Node service / CLI
{
  "extends": "@studio/tsconfig/node.json",
  "compilerOptions": {
    "outDir": "dist",
    "noEmit": false
  },
  "include": ["src/**/*.ts"]
}
```

```jsonc
// tsconfig.json — a Next.js / Expo / Vite app
{
  "extends": "@studio/tsconfig/bundler.json",
  "compilerOptions": {
    "jsx": "react-jsx"
  },
  "include": ["src/**/*.ts", "src/**/*.tsx"]
}
```

## Studio context

This package is part of the studio's **homogenize-projects** effort: shared
config lives in small public repos consumed by git reference, so every studio
project compiles against one source of truth instead of drifting per-repo copies.
It merges the previously-separate `NodeNext` base and `aca`'s `Bundler` config
(`verbatimModuleSyntax`, React Native variant) TypeScript configs into one `base`
plus `node` / `bundler` variants. The companion
[`@studio/eslint-config`](https://github.com/igonzalezespi/eslint-config) does the
same for ESLint.

Consumer migration of the product repos onto this package is a separate,
verification-heavy step and is intentionally **not** part of v0.1.0.

## License

MIT — see [LICENSE](./LICENSE). Public config, no secrets.
