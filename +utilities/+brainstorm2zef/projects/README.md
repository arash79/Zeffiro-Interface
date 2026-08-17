# brainstorm2zef — projects dump

## Folder purpose

Intended **output directory** for Brainstorm → Zeffiro conversion runs driven by `utilities.brainstorm2zef.run`. When a conversion config sets a project file name and save is enabled, generated Zeffiro `.mat` projects (and related dump artifacts) land here or at a path the config specifies. The folder may be empty in a fresh clone; that is normal.

This directory contains **no executable converter logic**. Conversion, compartment mapping, FEM mesh creation, and optional `zef_save` live in the parent package `+utilities/+brainstorm2zef/` (`run.m`, `zef_bst_create_project.m`, settings helpers, etc.).

## Main contents

| Item | Role |
|------|------|
| `README.txt` | Short human note: “projects created by the brainstorm2zef plugin” |
| `README.md` | This documentation |
| *(generated `.mat` / projects)* | Appear after successful conversions (not shipped in git) |
| *(optional dumps)* | e.g. compartment settings / surface mesh mats when `run_type` reload paths are used |

Sibling package areas (not in this folder):

| Path | Role |
|------|------|
| `../run.m` | Main entry: Brainstorm protocol → Zeffiro session |
| `../settings/` | Named settings basenames (default `zef_bst_default`) |
| `../zef_bst_*.m` | Create/edit/validate/compartment/mesh helpers |
| `../zef_bst_plugin_start.m` | Plugin/UI start if used from menus |

## Code functionality

No `.m` files here. Behaviour is entirely on the writer side:

1. `utilities.brainstorm2zef.run(config)` validates Brainstorm (`zef_bst_validate_environment`).
2. Builds compartments from Brainstorm surfaces (`zef_bst_create_project` path).
3. Creates FEM mesh (`zef_create_finite_element_mesh`).
4. Optionally `zef_save` when `config.project_file_name` is non-empty and `save_project` is true.
5. Returns `results` with `.success`, `.zef`, `.mesh_data`, `.errors`, `.warnings`, `.config`, `.processing_time`.

`config` highlights (defaults in `validate_and_set_defaults`):

- `.settings_file_name` — basename under `settings/`
- `.project_file_name` — if set, save `[name].mat`
- `.run_type` — 1 fresh from Brainstorm; 2 reload dumped compartment/surface files; 3 rejected (use `zef_bst_edit_project`)
- `.input_mode`, `.verbose`, `.save_project`, subject overrides, GPU / parallel options

## Workflow context

```
Brainstorm protocol (SUBJECTS)
        │
        ▼
utilities.brainstorm2zef.run(config)
        │
        ├─► zef_bst_create_project / compartment helpers
        ├─► zef_create_finite_element_mesh
        └─► optional zef_save → this folder (or config path)
```

After save, open projects with `zef_load` or `zeffiro_interface('open_project', ...)`. Distinct from runtime `data/example_projects` and segmentation libraries: those are shipped examples; this folder is a **local conversion dump**.

## Usage instructions

```matlab
config = struct();
config.settings_file_name = 'zef_bst_default';  % or another settings basename
config.project_file_name  = 'my_bst_subject';   % → my_bst_subject.mat when saved
config.run_type = 1;
config.verbose = true;

results = utilities.brainstorm2zef.run(config);
% Inspect results.zef / results.mesh_data; close with zef_close_all(results.zef) when done
```

Point output at this directory explicitly if your settings/helper resolves project paths here; otherwise check `results.config` for the effective save location. Then:

```matlab
zef_load('…/projects/my_bst_subject.mat');
```

## Important notes

- Do **not** commit large patient projects or identifiable imaging dumps to git.
- Empty folder after clone is expected.
- Requires Brainstorm on the MATLAB path and an initialized protocol (`bst_get('ProtocolInfo').SUBJECTS`).
- `run` does not close the Zeffiro session automatically — call `zef_close_all(results.zef)` when finished.
- `README.txt` is a one-line legacy pointer; keep it consistent with this README’s purpose statement.

## Developer guidance

- Keep this directory as a dump target only; all conversion logic stays in parent `+brainstorm2zef`.
- Add `.gitignore` patterns for `*.mat` (and large dump sidecars) here if developers start saving locally.
- When changing default save locations in `run` / `zef_bst_get_project_file_name`, update this README so dump expectations stay accurate.
- Do not place hand-edited “golden” projects here — use `data/example_projects` or documented fixtures instead.
- Prefer settings files under `../settings/` for reproducible conversions rather than ad-hoc scripts that write opaque mats into this folder without config.
