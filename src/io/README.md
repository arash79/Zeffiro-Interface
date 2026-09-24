# Project I/O (`src/io`)

## Folder purpose

Project **save/load** and Import/Export menu helpers for anatomy, sensors, figures, and related artifacts. Electrode CSV/DAT parsers are **`core.io.electrodes`** (not here). Measurement/reconstruction import dialogs live in **`zef_inv_import`** in this folder. Session text logs are under **`data/log/`** (not this folder).

## Main contents

### Save

| File | Role |
|------|------|
| `zef_save.m` | `save_switch` 1–10: full project, L, sources, sensors, segmentation, volume, overwrite save, reconstruction, figures, print. `zef_save(zef, file, path, switch)` sets `zef.file` / `zef.file_path` as char so headless export does not open a dialog. |
| `zef_save_system_settings.m` | **Script** → system INI |
| `zef_save_plugin_settings.m` | **Script** → plugin INI |

Project saves strip GUI handles (`zef_remove_object_handles`), close tools/figs, write `-v7.3`, may reopen mesh tools. `zef_load` expands a legacy one-struct MAT in memory and does **not** rewrite that file (upstream `load`+`save('-struct','zef_data')` could replace the project with an empty session).

### Load

| File | Role |
|------|------|
| `zef_load.m` | Open project MAT; DUNEuro MATLAB dumps are converted via `utilities.duneuro2zef.convert` before merge; batched load; `zef_canonicalize_sensors` once; rebuild sensors/compartments/GUI from the loaded fields; converts legacy single-var MAT |
| `zef_merge_project_data.m` | Copy scientific fields from the loaded MAT onto live `zef`, keeping live figures and controls. Clears `sensors_table_synced` so the startup sensors table is rebuilt from the loaded set instead of editing it. |

### Import

| File | Role |
|------|------|
| `zef_import_segmentation.m` | Modern `.zef`/`.mat` manifest (`box`/`segmentation`/`sensors`/`struct`/`script`) |
| `zef_import_segmentation_legacy.m` | Old 12-column `.zef` |
| `zef_import_mat_struct.m` | Merge arbitrary MAT fields |
| `zef_inv_import.m` | **Script.** Import → measurement data / reconstruction / current pattern / noise (`inv_import_type` 1–4). `uigetfile` `.mat`/`.dat`. |
| `zef_import_sensor_names.m` | **Script** DAT names → sensor table |
| `zef_import_resection_points.m` | **Script** resection coords |
| `zef_import_figure.m` | `.fig` → Figure tool |
| `zef_import_asc.m` | One-line ASC numeric parse |
| `zef_import_parcellation_colortable.m` / `_points.m` | Parcellation tool |
| `zef_get_mesh.m` | Load a surface file into points / triangles / `submesh_ind` (`points` / `triangles` / `stl` / `asc`). Used by compartment import and sensor-point loaders. |
| `zef_get_surface_mesh.m` | **Script.** Compartment-table **Import surface mesh** (STL/DAT) via `zef_get_mesh(..., 'full')`. |
| `zef_replace_project_fields.m` | **Script.** Rename legacy project fields after load (`current_version` ≤ 2.2 priorities; `< 4` `brain_ind` → `active_compartment_ind`). |

### Export

| File | Role |
|------|------|
| `zef_export_fem_mesh_as.m` | `nodes`, `tetra`, `domain_labels`, `name_tags` → MAT |
| (also via `zef_save` switches) | L / sources / sensors / segmentation / volume / reconstruction / figures |

### Brainstorm adapters (`import/`)

| File | Role |
|------|------|
| `zef_bst_2_zef_surface.m` | vertices/faces (mm) |
| `zef_bst_2_zef_sensors.m` | pos/ori/group/Type |
| `zef_bst_2_zef_atlas.m` | colortable + scout points |

Used by `utilities.brainstorm2zef.run` (metres ×1000 → mm). Not menu-wired alone.

## Code functionality

Menu and CLI entry points call these helpers with paths relative to the picked folder or `zef.data_path`. `.zef` `script` rows are trusted `evalc`. System fields stripped on save must stay aligned with `zef_remove_system_fields`.

## Workflow context

```
Project / Import / Export menus (zef_menu_tool)
  → src/io
  → zef fields / disk
CLI: zeffiro_interface('open_project'| 'import_to_new_project', …)
```

## Usage instructions

```matlab
zef = zeffiro_interface('open_project', ...
    fullfile(pwd,'data','example_projects','multicompartment_head_project.mat'));
zef = zeffiro_interface('start_mode','nodisplay', ...
    'import_to_new_project', fullfile(pwd,'data','segmentations', ...
    'multicompartment_head_project','import_segmentation.zef'));
```

## Important notes

- Electrode **files**: `+core/+io/+electrodes` + Import electrodes callback.
- Logs: `data/log/zeffiro_interface_*.log` — not under `src/io`.
- Large projects need MATLAB able to write HDF5-style `-v7.3` MAT files.

## Developer guidance

- New export mode = new `save_switch` **and** menu wire in `zef_menu_tool`.
- Keep Brainstorm adapters in `import/`; orchestration in `+utilities/+brainstorm2zef`.
- Pitfall: saving with live `h_*` handles still attached — always go through `zef_save` strip logic.
