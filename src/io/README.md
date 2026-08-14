# Project files and import (`src/io`)

This folder reads and writes Zeffiro projects and the anatomy/sensor files you import from the **Project**, **Import**, and **Export** menus. Electrode CSV/DAT import (**Import → Import electrodes**) is *not* here; that path is `core.gui.menu_tool.import_electrodes_callback` (`+core/+io/+electrodes`).

A saved project is a MATLAB v7.3 `.mat` whose variables are the `zef` fields **without live figure handles**. Load rebuilds the GUI from that struct.

## What a user does

### Open and save (Project menu)

Verified from `zef_menu_tool.m` + `zef_menu_tool_app_exported`:

| Menu item | What runs |
|-----------|-----------|
| **Project → Open project** | `zef_load` (file dialog `*.mat`) |
| **Project → Save** | `zef.save_switch=7; zef_save` — overwrite current path, or **Save as…** if none |
| **Project → Save as...** | `save_switch=1` — full project, always prompts |
| **Project → Save figures as...** | `save_switch=9` — all Figure-tool windows as `.fig` |
| **Project → Print figure to file as...** | `save_switch=10` — PNG / JPEG / TIFF of `gcf` |
| **Project → Exit** | `zef_close_all` (not an I/O function) |

`zef_load` starts a new project first (`zef_start_new_project`), loads fields in size batches with a waitbar, then rebuilds sensors/compartments and the main tools.

Full-project save (`1` and `7`) calls `zef_close_tools` and `zef_close_figs`, strips handles with `zef_remove_object_handles`, writes v7.3, then reopens Mesh / Mesh visualization (and Segmentation on **Save as...**).

Headless: `zef_save_nodisplay` is a **script** that uses the same `save_switch` without `uigetfile` when `zef.use_display` is 0.

### Export menu

| Menu item | `save_switch` / function | Written fields |
|-----------|--------------------------|----------------|
| **Export → Export lead field** | 2 | `L` |
| **Export → Export source space** | 3 | `source_positions`, `source_directions` |
| **Export → Export sensors** | 4 | `<current_sensors>_points`, `_directions` |
| **Export → Export segmentation data** | 5 | surfaces (`reuna_p`/`reuna_t` as `surface_mesh_*`) + sensors |
| **Export → Export volume data** | 6 | `nodes`, `tetrahedra`, `sigma`, … |
| **Export → Export reconstruction** | 8 | `reconstruction` (`.mat` or ASCII `.dat`) |
| **Export → Export FEM mesh** | `zef_export_fem_mesh_as` | `nodes`, `tetra`, `domain_labels` (separate function) |

### Import menu

| Menu item | Call |
|-----------|------|
| **Import → Import data to a new project** | confirm → `zef_start_new_project` (`new_empty_project=1`) → `zef_import_segmentation` → `zef_build_compartment_table` |
| **Import → Import data to project** | `zef_import_segmentation` (no reset) |
| **Import → Import new segmentation from folder (legacy)** | reset + `zef_import_segmentation_legacy` |
| **Import → Import segmentation update from folder (legacy)** | `zef_import_segmentation_legacy` |
| **Import → Import new ASCII project from folder** | reset + `zef_import_project` |
| **Import → Import ASCII project update from folder** | `zef_import_project` |
| **Import → Import volume data** | confirm → new project → `zef_import` (volume `.mat`) |
| **Import → Import measurement data** | `zef.inv_import_type=1; zef_inv_import` |
| **Import → Import noise data** | `inv_import_type=4` |
| **Import → Import reconstruction** | `inv_import_type=2` |
| **Import → Import current pattern** | `inv_import_type=3` |
| **Import → Import resection points** | `zef_import_resection_points` (**script**) |
| **Import → Import electrodes** | `core.gui.menu_tool.import_electrodes_callback` |

The two “Import data to …” labels are assigned in `zef_menu_tool.m` after the App Designer defaults (`Import new segmentation from folder` / `Import segmentation update from folder`).

Parcellation **Colortable** / **Points** buttons (Parcellation tool, not this menu) call `zef_import_parcellation_colortable` and `zef_import_parcellation_points`.

**Project → Open figure** is `zef_import_figure` then `zef_size_change`.

## Segmentation `.zef` files

`zef_import_segmentation` reads a comma-separated manifest (or a `.mat` that is handed to `zef_import_mat_struct`). Each row has a `type` field. Relative `filename` / `foldername` values are resolved against the folder you picked (or `folder_name` when you pass both arguments). After each segmentation or sensor row the importer applies the parameter profile and rebuilds the matching GUI table.

| `type` | What the row does |
|--------|-------------------|
| `box` | `zef_add_bounding_box` (optional `name`) |
| `segmentation` | Create or reuse a compartment by `name`. Load a surface (`filename` + `filetype`, or infer extension). Keywords used in the file: `merge`, `affine_transform` (4×4, default `eye(4)`), `invert`, `sigma`, `activity` / sources, colors, Brainstorm database fields, parcellation sidecars (`colortable`, `points`). |
| `sensors` | Create or reuse a sensor set by `name`. Optional `modality` (default `zef.imaging_method_cell{1}`), `on`, `visible`, `affine_transform`, electrode file. |
| `struct` | `zef_import_mat_struct` of that `.mat` (merge fields into `zef`). |
| `script` | `evalc` of the named MATLAB file in the importer’s workspace. Treat as trusted code. |

Legacy 12-column manifests use `zef_import_segmentation_legacy` (**Import → Import new/update segmentation from folder (legacy)**). Surfaces are typically FreeSurfer-style `.asc` parsed via `zef_import_asc`. Converters that *write* these manifests: `utilities.fs2zef.run`, `utilities.sn2zef`, `utilities.brainstorm2zef`.

Each data row is twelve comma-separated fields (optional 55-line `%` header skipped as `HeaderLines`):

| Column (1-based) | Meaning |
|------------------|---------|
| 1 | Sidecar basename (no extension). Sensors load `<name>.dat`; `mat_struct` loads `<name>.mat`; ASC/STL/DAT use the matching mesh files. |
| 2 | Token: `sensor_points`, `sensor_directions`, `mat_struct`, or a compartment name (`detail_1`…`detail_22`, `white_matter`, `grey_matter`, `csf`, `skull`, `scalp`). Those names map to fields `d1`…`d22`, `w`, `g`, `c`, `sk`, `sc`. |
| 3–8 | Sensors: scaling, xyz correction, xy/yz/zx rotations (first non-`0` wins). Compartments: scaling, `sigma`, priority, sources, display name, invert-winding (`0` = no). |
| 9 | Mesh format `ASC`/`STL`/`VOL`, or unused for sensors. Anything else loads `<name>_points.dat` + `<name>_triangles.dat`. `VOL` extracts the current tetrahedral boundary (`zef_surface_mesh`) instead of a file. |
| 10–12 | xyz translation added to loaded points. |

A second row for the same compartment concatenates points/triangles (legacy merge). `mat_struct` calls `zef_import_mat_struct` (same as modern `type=struct`).

Converters that *write* these manifests: `utilities.fs2zef.run`, `utilities.sn2zef`, `utilities.brainstorm2zef`.

`data/segmentations/` bundles are **import assets**, not auto-loaded at startup. Optional `default_project.mat` is named in `profile/zeffiro_interface.ini` and may be absent in a fresh clone.

## Brainstorm adapters (`import/`)

`zef_bst_2_zef_surface`, `zef_bst_2_zef_sensors`, `zef_bst_2_zef_atlas` convert Brainstorm subject geometry into Zeffiro arrays. Full pipelines live in `+utilities/+brainstorm2zef`; these files are the low-level converters.

## Settings INIs

**Settings → System settings (zeffiro_interface.ini)** / **Plugin settings** dialogs save through `zef_save_system_settings` and `zef_save_plugin_settings` (**scripts**).

## Scripting

```matlab
zef = zeffiro_interface('start_mode','nodisplay');
zef = zef_load(zef, 'my_project.mat', fullfile(projectRoot,'data'));
zef = zef_save(zef, 'out.mat', fullfile(projectRoot,'data'), 1);

% Same as Import → Import data to a new project (CLI helper on zeffiro_interface)
zef = zeffiro_interface('import_to_new_project', ...
    fullfile(projectRoot,'data','segmentations','multicompartment_head_project','import_segmentation.zef'));
```

Relative paths in CLI arguments default to `zef.data_path` (`data/`).

## Files

| File | Kind | Role |
|------|------|------|
| `zef_load.m` | function | Open `.mat` project |
| `zef_save.m` | function | `save_switch` 1–10 |
| `zef_save_nodisplay.m` | **script** | Headless `save_switch` |
| `zef_import_segmentation.m` | function | `.zef` / `.mat` compartments |
| `zef_import_segmentation_legacy.m` | function | Old 12-column `.zef` |
| `zef_import_project.m` | function | ASCII project index |
| `zef_import_mat_struct.m` | function | Merge arbitrary `.mat` fields |
| `zef_import.m` is in `gui/helpers` | function | Volume mesh `.mat` (menu **Import volume data**) |
| `zef_inv_import.m` is in `gui/helpers` | **script**-like | Measurements / recon / current pattern |
| `zef_import_sensor_names.m` | **script** | DAT names → sensors name table |
| `zef_import_resection_points.m` | **script** | Resection coordinates |
| `zef_import_figure.m` | function | Open `.fig` into Figure tool |
| `zef_import_asc.m` | function | One-line ASC numeric parse |
| `zef_import_surface_mesh_type.m` | function | STL/DAT type picker |
| `zef_export_fem_mesh_as.m` | function | FEM arrays to `.mat` |
| `zef_save_system_settings.m` | **script** | Write `zeffiro_interface.ini` |
| `zef_save_plugin_settings.m` | **script** | Write `zeffiro_plugins.ini` |

## Developer notes

- Always `zef_remove_object_handles` before serializing `zef`.
- New export: add a `save_switch` case **and** wire it in `zef_menu_tool.m`; document the integer here.
- System fields in `profile/zeffiro_interface.ini` must stay aligned with `zef_remove_system_fields`.
