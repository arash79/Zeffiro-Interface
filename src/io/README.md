# src/io

## Folder purpose

**Project persistence and data import/export** for Zeffiro Interface: saved `.mat` projects, segmentation bundles (`.zef` manifests, `.asc`/`.stl` surfaces), partial exports (lead field, FEM mesh, reconstruction), figure import, and Brainstorm-to-Zeffiro surface/sensor adapters.

Electrode CSV/DAT import for the Edit menu is handled by `+core/+io/+electrodes`, not this folder.

## Main contents

| File | Role |
|------|------|
| `zef_load.m` | Load `.mat` project; merge `zef_data`; strip/reapply system fields |
| `zef_save.m` | Multi-mode save (`save_switch`): full project, `L`, sources, mesh, recon, figures |
| `zef_save_nodisplay.m` | Headless save variants (no `uigetfile`) |
| `zef_import_segmentation.m` | Import `.zef` CSV manifest or `.mat` bundle into compartments |
| `zef_import_segmentation_legacy.m` | Legacy folder-based `.zef` import |
| `zef_import_project.m` | Load legacy ASCII `.zef` project index |
| `zef_import_mat_struct.m` | Merge arbitrary `.mat` struct fields into `zef` |
| `zef_import_figure.m` | Open `.fig` into figure tool |
| `zef_import_parcellation_points.m` / `zef_import_parcellation_colortable.m` | Atlas parcellation data |
| `zef_import_asc.m` | Parse ASC point clouds |
| `zef_import_surface_mesh_type.m` | File picker for `.stl` / `.dat` surfaces |
| `zef_export_fem_mesh_as.m` | Export `nodes`, `tetra`, `domain_labels` |
| `zef_save_system_settings.m` | Write `profile/zeffiro_interface.ini` from settings table |
| `zef_save_plugin_settings.m` | Write `profile/<profile>/zeffiro_plugins.ini` |
| `import/zef_bst_2_zef_surface.m` | Brainstorm surface → `reuna_p`/`reuna_t` arrays |
| `import/zef_bst_2_zef_sensors.m` | Brainstorm channels → sensor positions |
| `import/zef_bst_2_zef_atlas.m` | Brainstorm atlas → parcellation tables |

Scripts (no function line): `zef_import_sensor_names`, `zef_import_resection_points` — dialog-driven imports.

## Code functionality

**Load path:** read `.mat` v7.3 → `zef_remove_system_fields` → merge into workspace `zef` → `zef_build_compartment_table` → `zef_plugin` refresh.

**Save path:** `zef_close_tools` / `zef_close_figs` → `zef_remove_object_handles` → write `zef_data` struct (GUI handles stripped).

**Segmentation import:** `.zef` manifest lists compartment names, surface file paths, conductivities, and source flags; each surface is loaded and registered via `zef_create_compartment`.

**`save_switch` modes** (typical): 1=full project, 2=lead field only, 3=source space, 4=sensors, 5–6=FEM mesh variants, 7=reconstruction, 8=figures.

## Workflow context

| Trigger | Entry |
|---------|-------|
| `zef_menu_tool` Project menu | `zef_load`, `zef_save` |
| `zeffiro_interface` CLI | `open_project`, `import_to_new_project`, `save_project`, `export_fem_mesh` |
| Import menu | `zef_import_segmentation`, `zef_import` (volume), `zef_inv_import` (measurements) |
| `+utilities/+brainstorm2zef` | Calls `zef_bst_2_zef_*` adapters after BST export |
| Startup | Optional `zef_load(..., 'default_project.mat', data_path)` |

Writes logs are unrelated; see `src/core/zef_start_log.m` → `data/log/`.

## Usage instructions

```matlab
% GUI: File → Open / Save in menu tool

% CLI startup import
zef = zeffiro_interface('import_to_new_project', ...
    fullfile(projectRoot,'data','segmentations','multicompartment_head_project','import_segmentation.zef'));

% Programmatic save
zef = zef_save(zef, 'my_project.mat', fullfile(projectRoot,'data'), 1);

% Export FEM only
zef = zef_export_fem_mesh_as(zef);
```

## Important notes

- Projects are MATLAB v7.3 `.mat` files storing a `zef_data` struct without live `h_*` handles.
- `default_project.mat` is referenced in `profile/zeffiro_interface.ini` but may be absent in a fresh clone.
- Relative paths in CLI args default to `zef.data_path` (`data/`).
- Segmentation bundles under `data/segmentations/` are **import assets**, not auto-loaded at startup.

## Developer guidance

- New export formats: extend `zef_save` `save_switch` with a new case and document the switch number in the menu callback.
- Brainstorm adapters belong in `import/`; full BST pipelines belong in `+utilities/+brainstorm2zef`.
- Always call `zef_remove_object_handles` before serializing `zef` to avoid huge files with stale graphics handles.
- System fields listed in `profile/zeffiro_interface.ini` must stay in sync with `zef_remove_system_fields.m`.
