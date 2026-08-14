# `utilities.brainstorm2zef` — Brainstorm protocol → Zeffiro project

Builds a Zeffiro session from an **open Brainstorm protocol**: surfaces become compartments, then `zef_create_finite_element_mesh` runs. Unlike fs2zef/sn2zef, this converter does **not** write a folder of STL/ASC + `import_segmentation.zef` as its main product. It starts `zeffiro_interface('start_mode','nodisplay')` itself and optionally `zef_save`s a `.mat`.

GUI entry: `zef_bst_plugin_start` (figure named `ZEFFIRO-Brainstorm plugin`). Programmatic entry: `utilities.brainstorm2zef.run(config)`.

## What must exist

- Brainstorm on the MATLAB path (`exist('bst_get','file')`).
- An initialized protocol: `bst_get('ProtocolInfo')` must return a struct with `SUBJECTS`. `zef_bst_validate_environment` fails otherwise.
- Subject anatomy in that protocol matching `zef_bst.compartment_list` (default: Scalp, OuterSkull, InnerSkull, Cortex, Other, white, subcortical).
- Settings script under `settings/` (default `zef_bst_default.m`), loaded by `zef_bst_get_settings`.

No FreeSurfer/`SUBJECTS_DIR` requirement for `run` itself; Brainstorm already holds the surfaces.

## Public entry

```matlab
config = struct();
config.settings_file_name = 'zef_bst_default';  % basename in settings/
config.project_file_name = fullfile(pwd, 'data', 'bst_project');  % optional save
config.run_type = 1;      % 1 = fresh from Brainstorm; 2 = reload saved compartment dumps
config.input_mode = 1;    % 1 = use input files; 2 = ignore compartment_files
config.verbose = true;
% optional: subject_struct, subject_folder, use_gpu, parallel_processes, zef_bst overrides

results = utilities.brainstorm2zef.run(config);
% results.success, .zef, .mesh_data, .errors, .warnings, .processing_time
% Caller should zef_close_all(results.zef) when done — run does not close.
```

### `config` fields (`run` / `validate_and_set_defaults`)

| Field | Default | Meaning |
|-------|---------|---------|
| `settings_file_name` | `'zef_bst_default'` | Script in `settings/` (no `.m` needed) |
| `project_file_name` | `''` | If non-empty, `zef_save` to `[file_name].mat` |
| `run_type` | `1` | `1` fresh; `2` import previously written `*_compartment_settings.dat` + `*_surface_meshes.mat`. **3 is rejected** here — use `zef_bst_edit_project` or `zeffiro_interface('open_project',...)` |
| `input_mode` | `1` | `2` clears `zef_bst.compartment_files` |
| `verbose` | `true` | Also copied onto `zef_bst.verbose_mode` |
| `save_project` | true iff `project_file_name` non-empty | |
| `subject_struct` / `subject_folder` | empty | Overrides inside `zef_bst` |
| `use_gpu` / `parallel_processes` | `[]` | Passed into `zeffiro_interface` when set |
| `zef_bst` | `struct()` | Merged over the settings script |

## Pipeline (`run`)

1. `zef_bst_validate_environment`
2. `zef_bst_get_settings` (runs `zef_bst_init` then the settings `.m`)
3. `zeffiro_interface('start_mode','nodisplay', ...)`
4. `zef_bst_create_project` — `zef_add_bounding_box`, pull surfaces, `zef_add_compartment` per row
5. `zef_create_finite_element_mesh(zef)`
6. Copy mesh to `results.mesh_data`: **nodes divided by `zef_bst.unit_conversion`** (Zeffiro millimetres → metres for Brainstorm-side consumers). Tetra is `[zef.tetra zef.domain_labels]`. `name_tags` drops the last tag (bounding box).
7. Optional `zef_save`

## Coordinate frame

Compartment points/triangles come from Brainstorm surface files (`zef_bst_find_compartment` / `zef_bst_get_atlas_surfaces`). Triangle winding is flipped `(:,[1 3 2])` when stored on `zef`. Zeffiro mesh coordinates stay in the session length unit (typically mm). Only `results.mesh_data.nodes` is converted to metres.

## How the result is used

Keep `results.zef` and continue (lead field, inverse) in the same MATLAB session, or load the saved `.mat` later:

```matlab
zef = zeffiro_interface('start_mode', 'nodisplay', 'open_project', [file_name '.mat']);
```

There is no `import_to_new_project` `.zef` from this path unless you add one yourself.

## Plugin GUI

`zef_bst_plugin_start(folder_name, zef_bst, open_dialog)` builds figure `zeffiro_bst_plugin`, lists `zef_bst_*_fem_mesh_create.m` in this package (currently `zef_bst_default_fem_mesh_create`), and settings/project subfolders. `zef_bst_settings_file` is a dialog script for picking the settings `.m`.

## Settings / projects folders

- `settings/zef_bst_default.m` — factory `zef_bst` (mesh_resolution 3, compartment_list, GPU, inflation, …). It is a **script** that assigns `zef_bst.*`.
- `projects/` — intended dump location for plugin-created projects (`README.txt` only in-tree).

## Gaps

- `run_type` 3 is documented in some comments as “existing project” but `run` and `zef_bst_create_project` error if it is passed.
- Intermediate `*_compartment_settings.dat` / `*_surface_meshes.mat` are written next to the **settings file path**, not necessarily under `projects/`.
