// Bundler variant: Bundler resolution, verbatimModuleSyntax, DOM libs.
// Type-only import proves verbatimModuleSyntax keeps erasure clean.
import type { Shape } from "./shapes.js";

export function describe(shape: Shape): string {
  return `${shape.kind}`;
}

// DOM + DOM.Iterable must be available from the bundler lib set.
export function elementCount(root: ParentNode): number {
  let count = 0;
  for (const _child of root.children) count += 1;
  return count;
}
