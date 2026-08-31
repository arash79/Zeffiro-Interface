# Zeffiro architecture

This document describes the **actual** repository layout. Public function names (`zef_*`, `inverse.*Inverter`, `utilities.*`) are the API. Folder location is ownership, not a second API.

If you have not run the software yet, start with [getting-started.md](getting-started.md). Words such as lead field and reconstruction are in [glossary.md](glossary.md). Units and matrix layout: [conventions.md](conventions.md). Session fields: [zef-state.md](zef-state.md). Algorithms: [methods.md](methods.md).

## How a session is wired

One struct, `zef`, holds the project. Most GUI Inverse-tools menus call `zef_*` plugin start scripts that mutate that struct. Four **(class solver)** menus open `zef_open_class_inverse` and call `zef_inverse_run`. Scripts can call the same `zef_*` names, or the class path `zef_inverse_run` directly.

```text
User / GUI / script
        |
        v
   zef  (paths, compartments, mesh, sensors, L, measurements, reconstruction, h_*)
        |
        +-- src/mesh          surfaces → tetrahedra, sigma
        +-- src/sensors       attach electrodes / coils
        +-- src/forward       FEM → zef.L
        +-- plugins/*         Inverse-tools / domain GUI
              most → legacy *_iteration  ─────────────────┐
              four (class solver) → zef_inverse_run       │
        +-- src/inverse                                   │
              zef_inverse_run → utilities.cluster         │  both write
                    → inverse.*Inverter                   │  zef.reconstruction
        +-- src/gui/plot + src/visualization              │
        +-- src/io          save / load / import ─────────┘
```

Dependency direction we try to keep (legacy `evalin('base','zef')` still exists in places):

```text
GUI chrome/callbacks  →  app/session API  →  mesh, forward, inverse math
I/O                   →  session fields and files
Plugins               →  zef_* APIs and the zef struct
Class inverters       →  src/inverse orchestration + inverse.gmm/kf  (not GUI chrome)
```

## Repository tree

```text
Zeffiro-Interface/
├── zeffiro_interface.m      Public launch / CLI
├── zeffiro_setup.m          Submodules + generated src/app/zef_start_config.m
├── zeffiro_downloader.m     Fresh-install helper
├── src/                     Procedural zef_* runtime (on genpath)
│   ├── app/                 Session lifecycle (start, init, update, close)
│   ├── gui/                 Windows, callbacks, chrome, plot
│   │   ├── chrome/          Theme, layout, window manager
│   │   ├── apps/ tools/ callbacks/ update/ plot/ init/ open/ set/
│   ├── mesh/                FEM mesh pipeline + geometry predicates
│   ├── forward/             Lead fields, DTI, NSE, wave, PCG solvers
│   ├── inverse/             Orchestration + priors (not class solvers)
│   ├── io/                  Project save/load, segmentation, measurement import
│   ├── sensors/             Sensor sets, CEM/PEM attach helpers
│   ├── compartments/        Point-in-tissue / active-compartment queries
│   ├── parcellation/        Atlas ROIs
│   ├── visualization/       Colormaps, movies, graph_bank, time_series_tools
│   └── sensitivity/         zef_sensitivity_run façade
├── +core/                   core.types, core.io.electrodes, menu import callback
├── +inverse/                @*Inverter classes + inverse.gmm + inverse.kf
├── +utilities/              Converters, cluster dispatch, sensitivity library
├── plugins/                 GUI menu plugins (INI-discovered)
├── +tests/                  unit / integration / smoke / support
├── +examples/
├── profile/                 INI (session + plugin menus)
├── data/                    Example projects, electrodes; runtime logs under data/log/ (gitignored)
├── assets/                  GUI icons and figures
├── documentation/           LaTeX scientific manual
├── docs/                    Architecture and developer guides
├── external/                Optional git submodules
└── scripts/                 Maintainer tools (not on MATLAB path)
```

`src/app` is **not** `+core`. `plugins/` is **not** a MATLAB `+package`. `inverse.gmm` / `inverse.kf` are **not** GUI plugins.

## Runtime flow

```text
zeffiro_interface
  → addpath src/app + src/gui/chrome (restart-safe close)
  → addpath project root (packages) + genpath(src) + genpath(plugins) + profile + assets
  → zeffiro_setup / zef_start_config
  → zef_start → GUI tools
  → import anatomy (src/io) + sensors
  → src/mesh (Create FEM mesh)
  → src/forward (zef.L)
  → inverse: plugins/* (legacy iterations, or four class-solver dialogs)
             OR  zef_inverse_run → inverse.*Inverter
  → src/gui/plot + src/visualization
```

Forbidden (still true as a rule; some legacy scripts still `evalin('base','zef')`):

- Scientific modules must not *own* UI chrome.
- New code must not add mesh/forward math under `src/gui/`.
- Inverse kernels must not live in `plugins/` unless they are a GUI tool.

## Module responsibilities

| Directory | Responsibility | Allowed deps | Forbidden deps | Public entry | Extension |
|-----------|----------------|--------------|----------------|--------------|-----------|
| `src/app` | Session start/close/update, waitbar, plugin INI | profile, chrome (window restore) | solvers | `zef_start`, `zef_update`, `zef_close_all` | Defaults in `zef_init` + profile INI |
| `src/gui/chrome` | Theme, layout, docking | `zef` theme fields, assets | FEM/inverse math | `zef_ui_theme`, `zef_window_manager` | `zef_layout_*` + `zef_ui_ready` |
| `src/gui/tools` | Create tool windows | chrome, callbacks | New numerical solvers | `zef_segmentation_tool`, … | App Designer export + wrapper |
| `src/mesh` | Tetrahedral mesh | compartments, waitbar | GUI chrome | `zef_create_finite_element_mesh`, `zef_create_fem_mesh` | Mesh-tool pipeline functions |
| `src/forward` | `zef.L` and related physics | mesh, sensors, `core.types` | Inverse classes, chrome | `zef_lead_field_matrix` | New `lead_field_type` + FEM file |
| `src/inverse` | Bundle, filter, dispatch façade, priors | `utilities.cluster`, `+inverse` | Chrome | `zef_inverse_run` | Registry id + `@*Inverter` |
| `+inverse` | Class solvers | `src/inverse` helpers, `inverse.gmm/kf` | GUI | `inverse.MNEInverter`, … | `@NewInverter` + registry |
| `plugins/` | Menu tools | `zef_*`, session | Must not be the only copy of a class kernel | start functions in INI | Folder + INI row |
| `src/io` | Save/load/import | session, files | Must not restyle GUI | `zef_load`, `zef_save`, `zef_inv_import` | New import next to existing |
| `+utilities` | Converters, cluster, sensitivity lib | files, `zef_inverse_run` stack | GUI chrome | `utilities.fs2zef.run`, `dispatch_inverse` | New converter package |
| `+core` | Types + electrode parsers | files | Session lifecycle | `core.types.ZefSourceModel` | Enum members + `from()` |
| `external/` | Vendor submodules | their licenses | Do not treat as Zeffiro-owned | via `zef_start_config` | `.gitmodules` |

## Path / bootstrap

`zeffiro_interface`:

1. `addpath(src/app)` and `addpath(src/gui/chrome)` so restart can `zef_close_all` / `zef_window_manager`.
2. `addpath` project root (packages resolve; do **not** `addpath('+inverse')`).
3. `addpath(genpath(src))`, `genpath(plugins)`, `profile`, `assets/fig`.
4. `zeffiro_setup` writes `src/app/zef_start_config.m` for optional `external/` trees.

Do not `addpath` a `+package` folder. Do not `genpath` the whole repository (that would put `+tests` internals and `scripts` on the path).

## State

Session state is the struct `zef`, usually in the base workspace. GUI widgets are `zef.h_*`. New numerical code should take `zef` (or extracted arrays) as arguments rather than `evalin('base')` when practical. Existing mesh refine/smooth and some I/O scripts still require `zef` in the caller or base workspace; do not convert those without updating every caller ([developer-guide.md](developer-guide.md)).

## Plugin model

Profile `zeffiro_plugins.ini` CSV: `label, parent_menu_tag, callback`. Parent tags: `inverse_tools`, `forward_tools`, `multi_tools`, `settings`. `zef_plugin` appends `; zef_ui_ready_new_windows; zef_update;`.

Class inverse ids are **not** in that INI; they are in `utilities.cluster.inverse_method_registry`. Head-profile INIs do list four **callbacks** (`zef_eloreta_start`, …) that open `zef_open_class_inverse` rather than a legacy iteration.

Retired directory names (`tools/plugins`, `src/core`, `src/gui/helpers`, `src/auxiliary`, `+plugins`) and the removed `plugins/GithubPusher` helper must stay absent from git. `tests.smoke.ArchitectureLayoutTest` fails if they reappear. A local leftover copy on disk is not part of the published tree and is not on the MATLAB path.

## Known constraints

- Dual inverse tracks stay separate ([ADR-002](adr/ADR-002-dual-inverse-tracks.md)). Inverse-tools buttons are not class inverters except the four labelled **(class solver)** entries.
- `preconditioner_tolerance` / `cholinc_tol` are stored and unused. GPU PCG is Jacobi; CPU is SSOR or no-fill `ichol`. MEG and EIT copy those loops instead of calling `zef_transfer_matrix` ([conventions.md](conventions.md)).
- Buried CEM and PEM EIT have no solver; they error ([upstream.md](upstream.md)).
- Default Forward tools still offer several synthetic-source windows (current, legacy, patch, ROI). That overlap is supported, not accidental.

## Tests

```matlab
cd /path/to/Zeffiro-Interface
% project root must be on the path (zeffiro_interface does this)
import matlab.unittest.TestSuite
run(TestSuite.fromPackage('tests', 'IncludingSubpackages', true))
```

`runtests('+tests')` does not discover nested `tests.unit` / `tests.integration` / `tests.smoke`.

| Package | Role |
|---------|------|
| `tests.unit` | Solver kernels, UI tokens, types |
| `tests.integration` | Dispatch, cluster, class vs legacy |
| `tests.smoke` | End-to-end synthetic, windows, architecture layout |
| `tests.support` | Synthetic `zef` fixtures |

## Related

- [getting-started.md](getting-started.md), [glossary.md](glossary.md), [conventions.md](conventions.md), [zef-state.md](zef-state.md), [methods.md](methods.md)
- [developer-guide.md](developer-guide.md) — where to add a solver, GUI window, importer, plugin, colormap, or test; recipes for a class inverter and a menu plugin
- [upstream.md](upstream.md) — numbers and startup versus upstream `zeffiro_interface`
- [adr/](adr/)
- Folder READMEs under `src/`, `+inverse/`, `plugins/`, `+utilities/`
