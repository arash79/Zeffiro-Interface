# ADR-004: The `utilities.*` package name

## Status

Accepted.

## Decision

Converters, cluster inverse dispatch, the class-inverter frame loop, and small I/O helpers are the MATLAB package `utilities.*` at repository-root `+utilities/`.

Public entry points include `utilities.fs2zef.run`, `utilities.sn2zef.run`, `utilities.brainstorm2zef.run`, `utilities.duneuro2zef.convert` / `import_duneuro_project`, `utilities.cluster.dispatch_inverse`, and `utilities.inverse.run_frame_loop`.

## Why

The name is already a scripting API. Renaming it to `utils`, `helpers`, or folding it into `+core` would break cluster jobs and documented converters without changing behaviour.

## Consequences

- Do not `addpath('+utilities')`. Add the project root so MATLAB resolves `utilities.*`.
- Do not introduce a second public package for the same operations.
- Maintainer lint/indent tools live in `utilities.dev` and are not part of the inverse runtime.
