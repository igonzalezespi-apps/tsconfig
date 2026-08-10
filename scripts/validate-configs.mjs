// Validates each shared tsconfig actually compiles under the installed TypeScript.
// Catches invalid/renamed/removed compilerOptions and JSON syntax errors that
// only surface when `tsc` parses an extending project.
//
// For each config we run, against a tiny fixture that `extends` it:
//   1. `tsc --noEmit`     — the config + sample type-check cleanly
//   2. `tsc --showConfig` — the resolved config is well-formed JSON
//
// Any non-zero exit fails the whole run. No deps beyond TypeScript itself.

import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(__dirname, "..");

/** @type {readonly string[]} the config names exported by package.json */
const CONFIGS = ["base", "node", "bundler"];

/**
 * Run a `tsc` invocation against a fixture project and report pass/fail.
 * @param {string} label human-readable step name
 * @param {readonly string[]} args arguments passed to `tsc`
 * @returns {boolean} true on exit code 0
 */
function runTsc(label, args) {
  const result = spawnSync("npx", ["tsc", ...args], {
    cwd: repoRoot,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  });

  if (result.error) {
    console.error(`  FAIL  ${label}: ${result.error.message}`);
    return false;
  }
  if (result.status !== 0) {
    console.error(`  FAIL  ${label} (exit ${result.status})`);
    const output = `${result.stdout ?? ""}${result.stderr ?? ""}`.trim();
    if (output) console.error(output.replace(/^/gm, "    "));
    return false;
  }
  console.log(`  ok    ${label}`);
  return true;
}

let allPassed = true;

for (const name of CONFIGS) {
  console.log(`\n• ${name}.json`);
  const project = join("test", name, "tsconfig.json");

  // 1. type-check the fixture (config must be valid AND the sample must compile)
  const typeChecked = runTsc(`tsc --noEmit -p ${project}`, ["--noEmit", "-p", project]);

  // 2. resolve the config to JSON (catches bad extends chains / malformed JSON).
  //    --showConfig prints to stdout; we only care that it exits 0.
  const configResolved = runTsc(`tsc -p ${project} --showConfig`, [
    "-p",
    project,
    "--showConfig",
  ]);

  if (!typeChecked || !configResolved) allPassed = false;
}

if (!allPassed) {
  console.error("\n✖ One or more tsconfig validations failed.");
  process.exit(1);
}

console.log("\n✔ All tsconfig configs validated.");
