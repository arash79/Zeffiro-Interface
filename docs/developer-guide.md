# Developer guide

Where to put new work, and the usual recipes for a solver, plugin, converter, or core window. Architecture overview: [architecture.md](architecture.md). Units and `zef` fields: [conventions.md](conventions.md), [zef-state.md](zef-state.md). Git workflow, tests, and docs habits: [CONTRIBUTING.md](../CONTRIBUTING.md).

## Where do I add…?

| Feature | Location | Also |
|---------|----------|------|
| Inverse **algorithm** (programmatic / cluster) | `+inverse/@NewInverter` | `utilities.cluster.inverse_method_registry`; test under `+tests/+unit` or `+integration`; `+inverse/README.md` table |
| Inverse **GUI** (legacy iteration) | `plugins/NewTool/` + start function | Row in each `profile/*/zeffiro_plugins.ini` that should show it |
| Inverse **GUI** (class dialog) | `plugins/NewTool/` + `zef_open_class_inverse` spec | INI label should include `(class solver)`; recipe below |
| Shared Kalman/GMM **kernel** | `+inverse/+kf` or `+inverse/+gmm` | Not under `plugins/` |
| Forward / lead-field solver | `src/forward/lead_field` | `zef_lead_field_matrix` dispatch; `src/forward/README.md` |
| Mesh algorithm | `src/mesh` | Mesh-tool button already calls `zef_create_finite_element_mesh` |
| Electrode file parser | `+core/+io/+electrodes` | Keep `core.io.electrodes.*` |
| Project / segmentation I/O | `src/io` | |
| Anatomy converter (FS, SimNIBS, …) | `+utilities/+fs2zef` (or sibling) | Public name `utilities.<name>.run` |
| GUI window (core tools) | `src/gui/apps` + `src/gui/tools` | Layout in `src/gui/chrome`; events in `callbacks`; sync in `update` |
| Visualization LUT | `src/visualization/colormaps` | Register in `zef_init` `colormap_cell` |
| Mesh-vis graph | `src/visualization/graph_bank` | Dir-discovered next to `zef_histogram` |
| Plugin | `plugins/` | See `plugins/README.md` |
| Unit test | `+tests/+unit` | Fixtures: `tests.support.createSyntheticInverseZef` |
| Example script | `+examples` | |

## Naming

- Procedural runtime: `zef_*` filenames matching the function name.
- Packages: `core.*`, `inverse.*`, `utilities.*`, `tests.*`, `examples.*`.
- Do not introduce a second public name for the same operation.
- Do not name folders `utils`, `helpers`, `misc`, or `common` for mixed domain code.

## Package rules

- Add the **project root** to the path, never `addpath('+inverse')`.
- `private/` folders only when a single parent directory should see the functions.
- Class inverter: implement `invert`; inherit `inverse.CommonInverseParameters` unless there is a strong reason not to.

## Prohibited patterns

- Mesh/forward/inverse math in `src/gui/chrome` or `src/gui/callbacks`.
- GUI chrome in `src/forward` or `+inverse`.
- New `eval` / `evalin` / `assignin` except where the existing session scripts already require caller-workspace `zef`.
- `addpath(genpath(entire repo))`.
- Treat `external/` as first-party code.
- Permanent aliases for internal functions after a rename.

## Public vs internal

**Safe to call from scripts and plugins:** `zeffiro_interface`, `zef_update`, `zef_close_all`, `zef_create_finite_element_mesh`, `zef_lead_field_matrix`, `zef_inverse_run`, `zef_load` / `zef_save`, `core.types.ZefSourceModel`, `core.io.electrodes.*`, `utilities.*.run` converters, `utilities.cluster.dispatch_inverse` (usually via `zef_inverse_run`).

**Internal:** `zef_ui_*` layout helpers, mesh scripts that mutate caller workspace (`zef_refinement_step`, `zef_smoothing_step`), inverter `invert` internals, generated `zef_start_config.m`.

MATLAB does not hide `src/` internals (everything is on `genpath`). Ownership is by folder + this guide, not `private/` for the whole tree.

## Lead-field PCG pitfall

`zef_transfer_matrix` is **not** the only electrode PCG. MEG and EIT copy the same loops. A change that only edits `zef_transfer_matrix` leaves magnetometer, gradiometer, and EIT behaviour behind. GPU always uses Jacobi (`1./diag(A)`); `zef.preconditioner` is a CPU-only choice (SSOR vs `ichol` nofill). `preconditioner_tolerance` is stored and unused. Details: [conventions.md](conventions.md).

## How to add a class inverse method

Inverse-tools menus without **(class solver)** still call `plugins/*` iterations. The programmable / cluster path is a class under `+inverse` plus a registry id. Existing **(class solver)** menus already open a class dialog. Do not point a legacy Start button at a class inverter unless that product change is intended ([ADR-002](adr/ADR-002-dual-inverse-tracks.md)).

1. Add `+inverse/@NewInverter/` with `classdef NewInverter < inverse.CommonInverseParameters`. Implement at least `invert`. Add `initialize` / `precompute` / `smoother` only if the frame loop needs them (`utilities.inverse.run_frame_loop` calls them when they exist).
2. Register the id in `+utilities/+cluster/inverse_method_registry.m` (case-insensitive string → `execution_kind` `"class"` and `class_name` `"inverse.NewInverter"`).
3. Document constructor properties in `+inverse/@NewInverter/README.md` and add a row to [`+inverse/README.md`](../+inverse/README.md).
4. Add a unit test under `+tests/+unit` (synthetic `L`, compare against a frozen kernel or assert shapes). Add a dispatch smoke under `+tests/+integration` that calls `zef_inverse_run(zef, 'newid', 'execution', 'local')`.
5. If the solver needs a shared Kalman/GMM kernel, put that math in `+inverse/+kf` or `+inverse/+gmm`, not in the plugin folder.

Users then run:

```matlab
[zef, r] = zef_inverse_run(zef, 'newid', 'execution', 'local', ...
    'MethodParams', struct('your_property', value));
```

`MethodParams` is copied onto the inverter. Prefer that over mutating `zef.inv_*` for cluster jobs.

## How to add a class-solver Inverse-tools dialog

Use this only when the menu should run `zef_inverse_run`, not a legacy `*_iteration`. Pattern: `plugins/ELORETA`.

1. Add `plugins/NewTool/zef_newtool_start.m` that calls `zef_tool_start(zef, 'zef_newtool_window', …)`.
2. Add `zef_newtool_window.m` that fills `spec.method_id`, `spec.title`, `spec.method_fields`, then `zef = zef_open_class_inverse(zef, spec)`. Field structs: `name`, `label`, `kind` (`numeric` / `dropdown` / `checkbox`), `value`, `items`, `scope` (`method` → `MethodParams`, `zef` → session fields).
3. Add a CSV row `Label (class solver),inverse_tools,zef_newtool_start` to each `profile/*/zeffiro_plugins.ini` that should show it.
4. Do not reimplement the frame loop in the plugin folder. The dialog’s Start already calls `zef_inverse_run`.

`zef_open_class_inverse` lives in `src/gui/open/`. It requires `zef.L` and `zef.measurements` before invert. Widget tags are `zef_inv_<name>` (used by `tests.unit.ClassInverseDialogTest`).

## How to add a GUI plugin

A plugin is a folder under `plugins/` plus a CSV row in each `profile/*/zeffiro_plugins.ini` that should show it. It is **not** a MATLAB `+package`.

1. Create `plugins/NewTool/` with a start function on the path (`zef_newtool_start` is the usual name) that opens the window.
2. Add a row `Menu label,parent_tag,callback` to the relevant INI files. Parent tags: `inverse_tools`, `forward_tools`, `multi_tools`, `settings`. `zef_plugin` appends `; zef_ui_ready_new_windows; zef_update;` to the callback.
3. Inverse plugins that write `zef.reconstruction` typically call `zef_processLeadfields`, `zef_getFilteredData` / `zef_getTimeStep`, then `zef_postProcessInverse`. They need `zef.L`, `zef.source_interpolation_ind`, and `zef.measurements`.
4. Keep numerical kernels that the class track also uses in `+inverse`. A legacy inverse plugin stays a thin window around a `zef_*_iteration` function. For a menu that should run the class inverter, use the class-solver dialog recipe above instead.

Switching profile and re-running `zef_plugin` rebuilds the menu. A few Forward-tools items are hardcoded in `zef_menu_tool.m` (Find synthetic source, Generate synthetic EIT data, Butterfly plot) and do not come from the INI.

## How to add an anatomy converter

Follow `utilities.fs2zef.run`: a package under `+utilities/+<name>/` with a public `run` entry that writes a folder of surfaces and an `import_segmentation.zef` manifest. Keep millimetre coordinates unless the sibling README states otherwise. DUNEuro is the exception: `utilities.duneuro2zef.convert` maps a MATLAB project into native `zef` fields and is also wired through Open project. Do not put converter math in `src/gui`.

## How to add a core GUI window

Export the App Designer layout to `src/gui/apps/`, wrap it in `src/gui/tools/`, put events in `src/gui/callbacks/`, widget→`zef` copy in `src/gui/update/`, and layout in `src/gui/chrome` (`zef_layout_<tool>` registered from `zef_ui_ready`). Always create figures through `zef_window_manager('standalone', h)`. End table mutations with `zef_update`.

## After you change something

```matlab
import matlab.unittest.TestSuite
run(TestSuite.fromPackage('tests', 'IncludingSubpackages', true))
```

If you moved a public `zef_*` file, update [architecture.md](architecture.md), the folder README, and `tests.smoke.ArchitectureLayoutTest` in the same change. This repository has **no GitHub Actions / MATLAB CI** in-tree; tests are run locally (or in whatever CI a fork adds).
