#!/usr/bin/env bash
# ============================================================================
# bootstrap.sh — one-time per-clone / per-machine onboarding for this repo
# ============================================================================
# A committed config can DECLARE the enforcement floor but cannot switch it on
# by itself. This script performs the imperative, per-machine × per-repo steps:
#
#   1. Installs the Claude Code plugins this repo declares. .claude/settings.json
#      only lists them under enabledPlugins + declares the marketplace under
#      extraKnownMarketplaces; installation is a separate imperative act (its
#      omission is silent), so it lives here.
#   2. Points git at the repo's hook dir so the private-reference pre-commit
#      guard runs. That guard is a no-op wherever the private denylist is absent
#      (a fork, any off-maintainer machine), so this is always safe.
#   3. Refreshes and verifies the vendored bash-guard against its canonical
#      source when the plugin's guard tooling is reachable.
#
# Safe to re-run. Neutral by construction — it names no private repository.
# ============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

PLUGINS=(core-dev studio-policy stack-node)

# --- 1. Plugins (project scope; the 'ivan' marketplace is declared in
#        .claude/settings.json → extraKnownMarketplaces) -----------------------
if command -v claude >/dev/null 2>&1; then
  for p in "${PLUGINS[@]}"; do
    echo "bootstrap: installing ${p}@ivan (project scope)"
    claude plugin install "${p}@ivan" --scope project \
      || echo "bootstrap: WARN could not install ${p}@ivan — install it manually later" >&2
  done
else
  echo "bootstrap: 'claude' CLI not found — skipping plugin install." >&2
  echo "bootstrap: later run: claude plugin install core-dev@ivan studio-policy@ivan stack-node@ivan --scope project" >&2
fi

# --- 2. Private-reference pre-commit guard ---------------------------------
if [ -d .githooks ]; then
  git config core.hooksPath .githooks
  echo "bootstrap: core.hooksPath -> .githooks (private-reference guard active where the denylist exists)"
fi

# --- 3. Vendored guard: sync + verify, only if the tooling is reachable -----
# guard-sync refreshes scripts/hooks/bash-guard.sh from its canonical source;
# guard-verify asserts parity + wiring + liveness. Both ship with the core-dev
# plugin. Inside a Claude session ${CLAUDE_PLUGIN_ROOT} points at it; otherwise
# probe the local plugin cache. Absent → skip with a hint (never fail the boot).
#
# The cache keys every plugin by VERSION — <cache>/<marketplace>/core-dev/<version>/scripts —
# so the version-less glob this used to carry matched nothing and the whole step
# degraded into a silent no-op even with the plugin installed. Probe by locating
# the script itself, newest version wins, maintainer's marketplace first.
find_core_dev_scripts() {
  local root hit
  if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -d "${CLAUDE_PLUGIN_ROOT}/scripts" ]; then
    printf '%s\n' "${CLAUDE_PLUGIN_ROOT}/scripts"
    return 0
  fi
  for root in \
    "$HOME/.claude/plugins/cache/ivan/core-dev" \
    "$HOME/.claude/plugins/cache" \
    "$HOME/.claude/plugins/marketplaces"; do
    [ -d "$root" ] || continue
    hit="$(find "$root" -type f -name 'guard-sync.sh' -path '*core-dev*' 2>/dev/null | sort -V | tail -1)"
    [ -n "$hit" ] && { printf '%s\n' "$(dirname "$hit")"; return 0; }
  done
  return 1
}

if SCRIPTS_DIR="$(find_core_dev_scripts)"; then
  # `cmd || true` swallowed the exit code of the ONE step whose entire job is to
  # report failure: guard-verify checks that the vendored guard matches the
  # canonical, is cabled, and actually fires. With `|| true` a red guard-verify
  # left bootstrap exiting 0, so onboarding reported success over a guard that
  # was stale, un-cabled or inert — the exact fail-open this script exists to
  # close. `if/fi` so a real failure is a real failure; a MISSING script is still
  # not an error (the tool is optional), and that distinction is the whole point.
  if [ -x "$SCRIPTS_DIR/guard-sync.sh" ]; then
    bash "$SCRIPTS_DIR/guard-sync.sh" --repo "$ROOT"
  fi
  if [ -x "$SCRIPTS_DIR/guard-verify.sh" ]; then
    bash "$SCRIPTS_DIR/guard-verify.sh" --repo "$ROOT"
  fi
else
  echo "bootstrap: core-dev guard tooling not found locally — run /guard-verify inside a Claude session to check the vendored guard." >&2
fi

echo "bootstrap: done."
