// Node variant: NodeNext module + moduleResolution. Inherits base strictness.
type Json =
  | string
  | number
  | boolean
  | null
  | readonly Json[]
  | { readonly [key: string]: Json };

export function parse(input: string): Json {
  const value: unknown = JSON.parse(input);
  return value as Json;
}

export function sizeOf(values: readonly number[]): number {
  const head = values[0]; // number | undefined under noUncheckedIndexedAccess
  return head ?? values.length;
}
