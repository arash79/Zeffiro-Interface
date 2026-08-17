# +utilities/+brainstorm2zef

## Folder purpose

Convert a **Brainstorm** protocol into a Zeffiro project (compartments + FEM mesh), typically under `nodisplay`. Unlike `fs2zef` (FreeSurfer surfaces → ASC/STL/`.zef` dump), this path drives a live Zeffiro session and optional project save.

## Main contents

| Item | Role |
|------|------|
| `run.m` | `utilities.brainstorm2zef.run(config)` — main programmatic entry |
| `zef_bst_plugin_start.m` | GUI “ZEFFIRO-Brainstorm plugin” |
| `zef_bst_create_project.m` | Surfaces → compartments (no mesh yet) |
| `zef_bst_default_fem_mesh_create.m` | Discovered mesh-create script (`zef_bst_*_fem_mesh_create.m`) |
| `zef_bst_init` / `zef_bst_get_settings` / validators | Defaults and checks |
| `zef_bst_edit_project.m` | Edit / reload flows (run_type nuances) |
| `settings/` | Preset scripts (e.g. `zef_bst_default.m`) |
| `projects/` | Optional dump target for saved `.mat` / compartment dumps |
| Adapters in `src/io/import/zef_bst_2_zef_*` | Low-level BST → Zeffiro field mapping |

## Code functionality

`run` pipeline (typical):

1. Validate Brainstorm environment / settings.
2. `zeffiro_interface('start_mode','nodisplay')`.
3. `zef_bst_create_project` — build compartments from BST surfaces.
4. `zef_create_finite_element_mesh` — FEM.
5. Extract `mesh_data` (nodes often converted to metres via `/unit_conversion`).
6. Optional `zef_save` — does **not** auto-close the session.

Config highlights: `settings_file_name`, `project_file_name`, `run_type` (1 fresh / 2 reload dumps; prefer `zef_bst_edit_project` for some edit paths), `input_mode`, `verbose`, GPU/parallel overrides. Defaults include a Scalp…subcortical `compartment_list` and `unit_conversion=1000`.

## Workflow context

```
Brainstorm protocol
  → utilities.brainstorm2zef.run / plugin
  → src/mesh + lead_field (afterward, user-driven)
```

Siblings: `fs2zef`, `sn2zef`, `duneuro2zef`.

## Usage instructions

```matlab
cfg = struct();  % see settings presets / help utilities.brainstorm2zef.run
utilities.brainstorm2zef.run(cfg);
% or open the GUI plugin: zef_bst_plugin_start
```

## Important notes

- Prefer not nesting inside an already-open GUI session — use nodisplay/`run` or a clean start.
- `projects/` may be empty in a fresh clone; set explicit output paths.
- Conductivities / DOF defaults come from `zef_bst_init` and settings overlays.

## Developer guidance

- Keep BST I/O adapters in `src/io/import`; keep orchestration here.
- Document any new `zef_bst_*_fem_mesh_create` discovery name in this README.
- Pitfall: mixing fs2zef ASC imports with Brainstorm run without clearing compartments.
