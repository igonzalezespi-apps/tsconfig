// Exercises the base config's strict flags so a broken/loosened config is caught.
// - noUncheckedIndexedAccess: indexed access is `T | undefined`
// - exactOptionalPropertyTypes: optional means "absent", not "undefined"
// - useUnknownInCatchVariables: caught error is `unknown`
// - noFallthroughCasesInSwitch + noImplicitOverride: exhaustive, explicit code

type Shape =
  | { readonly kind: "circle"; readonly radius: number }
  | { readonly kind: "square"; readonly side: number };

function area(shape: Shape): number {
  switch (shape.kind) {
    case "circle":
      return Math.PI * shape.radius ** 2;
    case "square":
      return shape.side * shape.side;
    default: {
      const _exhaustive: never = shape;
      return _exhaustive;
    }
  }
}

function firstArea(shapes: readonly Shape[]): number {
  const first = shapes[0]; // Shape | undefined under noUncheckedIndexedAccess
  if (first === undefined) return 0;
  return area(first);
}

export function run(): number {
  try {
    return firstArea([{ kind: "circle", radius: 2 }]);
  } catch (err: unknown) {
    return err instanceof Error ? -1 : -2;
  }
}
