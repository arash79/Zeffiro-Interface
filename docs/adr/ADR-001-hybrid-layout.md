# ADR-001: Hybrid MATLAB layout

## Status

Accepted.

## Decision

The runtime is three cooperating trees, not a single package:

- `src/` — procedural `zef_*` session, mesh, forward, I/O, GUI
- `+core/`, `+inverse/`, `+utilities/` — MATLAB packages (`core.*`, `inverse.*`, `utilities.*`)
- `plugins/` — GUI tools discovered from `profile/<name>/zeffiro_plugins.ini`

Public names (`zef_*`, `inverse.*Inverter`, `utilities.*.run`) are the API. Folder location is ownership.

## Why

MATLAB packages cannot host the historical `zef_*` session scripts without renaming every caller. Plugins must stay ordinary functions on `addpath(genpath(plugins))` so INI callbacks and App Designer exports keep working. New inverse math and converters belong in packages so cluster jobs and tests can call them without opening a figure.

## Consequences

- Add the **project root** to the path. Do not `addpath('+inverse')` or `addpath(genpath(entire repo))`.
- `src/app` is not the `+core` package. `plugins/` is not a `+package`.
- Retired directory names (`tools/plugins`, `src/core`, `src/gui/helpers`, `src/auxiliary`, `+plugins`) must stay absent. `tests.smoke.ArchitectureLayoutTest` guards that.
