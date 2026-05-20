# +utilities/+brainstorm2zef

## Purpose of this folder

Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.

## Contents

Subfolders:
- `projects/`
- `settings/`

MATLAB sources:
- `zef_bst_settings_file.m` — **utilities.brainstorm2zef.function zef_bst_settings_file**: Function zef bst settings file.
- `run.m` — **utilities.brainstorm2zef.run**: Run.
- `zef_bst_init.m` — **utilities.brainstorm2zef.zef_bst**: Zef bst.
- `zef_bst_compartment_settings.m` — **utilities.brainstorm2zef.zef_bst_compartment_settings**: Zef bst compartment settings.
- `zef_bst_create_compartment_data.m` — **utilities.brainstorm2zef.zef_bst_create_compartment_data**: Zef bst create compartment data.
- `zef_bst_create_project.m` — **utilities.brainstorm2zef.zef_bst_create_project**: Zef bst create project.
- `zef_bst_default_fem_mesh_create.m` — **utilities.brainstorm2zef.zef_bst_default_fem_mesh_create**: Zef bst default fem mesh create.
- `zef_bst_edit_project.m` — **utilities.brainstorm2zef.zef_bst_edit_project**: Zef bst edit project.
- `zef_bst_find_compartment.m` — **utilities.brainstorm2zef.zef_bst_find_compartment**: Zef bst find compartment.
- `zef_bst_get_atlas_surfaces.m` — **utilities.brainstorm2zef.zef_bst_get_atlas_surfaces**: Zef bst get atlas surfaces.
- `zef_bst_get_compartment_property.m` — **utilities.brainstorm2zef.zef_bst_get_compartment_property**: Zef bst get compartment property.
- `zef_bst_get_input_mode.m` — **utilities.brainstorm2zef.zef_bst_get_input_mode**: Zef bst get input mode.
- `zef_bst_get_project_file_name.m` — **utilities.brainstorm2zef.zef_bst_get_project_file_name**: Zef bst get project file name.
- `zef_bst_get_run_type.m` — **utilities.brainstorm2zef.zef_bst_get_run_type**: Zef bst get run type.
- `zef_bst_get_settings.m` — **utilities.brainstorm2zef.zef_bst_get_settings**: Zef bst get settings.
- `zef_bst_get_settings_file_name.m` — **utilities.brainstorm2zef.zef_bst_get_settings_file_name**: Zef bst get settings file name.
- `zef_bst_normalize_compartment_name.m` — **utilities.brainstorm2zef.zef_bst_normalize_compartment_name**: Zef bst normalize compartment name.
- `zef_bst_plugin_start.m` — **utilities.brainstorm2zef.zef_bst_plugin_start**: Zef bst plugin start.
- `zef_bst_validate_environment.m` — **utilities.brainstorm2zef.zef_bst_validate_environment**: Zef bst validate environment.
- `zef_bst_validate_settings.m` — **utilities.brainstorm2zef.zef_bst_validate_settings**: Zef bst validate settings.

Other files:
- `README.txt`

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **utilities.brainstorm2zef.function zef_bst_settings_file**: GUI callback or dialog (`function zef_bst_settings_file`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `utilities.brainstorm2zef.function zef_bst_settings_file` from MATLAB with the project root on the path.`
- ``[results] = utilities.brainstorm2zef.run(config)` with project root and `src` on the path.`
- `Call `utilities.brainstorm2zef.zef_bst` from MATLAB with the project root on the path.`
- ``[compartment_settings] = utilities.brainstorm2zef.zef_bst_compartment_settings(zef_bst, surface_meshes)` with project root and `src` on the path.`
- ``[[compartment_settings, surface_meshes, zef]] = utilities.brainstorm2zef.zef_bst_create_compartment_data(settings_file_name, zef_bst, zef)` with project root and `src` on the path.`
- ``[zef] = utilities.brainstorm2zef.zef_bst_create_project(settings_file_name, project_file_name, run_type, input_mode, …)` with project root and `src` on the path.`
- ``[out_cell] = utilities.brainstorm2zef.zef_bst_default_fem_mesh_create(run_type, input_mode, settings_file_name, project_file_name, …)` with project root and `src` on the path.`
- ``utilities.brainstorm2zef.zef_bst_edit_project(project_file_name)` with project root and `src` on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Populated `zef` struct (from `zeffiro_interface` or `zef_load`).
- Package namespaces `core.*`, `inverse.*`, `utilities.*` via project-root `addpath`.
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
