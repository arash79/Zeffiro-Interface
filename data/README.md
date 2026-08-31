# data

## Folder purpose

**Bundled and runtime data root** for Zeffiro. `zeffiro_interface` sets `zef.data_path = fullfile(program_path, 'data')` and uses it as the default directory when a CLI path has no folder (project open/import/save) and for session logs.

## Main contents

| Subfolder / file | Contents |
|------------------|----------|
| `segmentations/multicompartment_head_project/` | FreeSurfer-style `.asc` surfaces, `import_segmentation.zef`, electrodes, parcellation colortables |
| `example_projects/` | Saved `.mat` projects (multicompartment head, asteroid gravity/radar, ary sphere) |
| `electrodes/` | Standard EEG cap `.dat` layouts (Biosemi, EGI, 10–20, …) |
| `itokawa_model/` | Asteroid demo `.stl` meshes |
| `log/` | Runtime `zeffiro_interface_*.log` files from `zef_start_log` (gitignored) |
| `default_project.mat` | Optional warm-start project — **not** shipped in a fresh clone |

## Code functionality

**Startup load** (if file exists): `zef_load(zef, 'default_project.mat', zef.data_path)`. Import segmentation: GUI or CLI passes path to `import_segmentation.zef`; manifest lists relative paths into `segmentations/multicompartment_head_project/*.asc`. Logs: `zef_start_log` creates `data/log/` and prunes old files per `max_n_log_files` in system INI. Examples write outputs here (e.g. `data/lead_field_example.mat`).

## Workflow context

| Consumer | Path used |
|----------|-----------|
| `zeffiro_interface` CLI args | Relative paths with no directory → `data/` (not `example_projects/` or `segmentations/` alone) |
| `+examples/+importing` | `data/segmentations/.../import_segmentation.zef` |
| `+core` electrode import | User-selected files; sample caps in `electrodes/` |
| `profile/zeffiro_interface.ini` | `save_file_path = ./data/` |

Not on MATLAB path as code — data only.

## Usage instructions

```matlab
zef = zeffiro_interface('import_to_new_project', ...
    fullfile(projectRoot,'data','segmentations','multicompartment_head_project','import_segmentation.zef'));

zef = zeffiro_interface('open_project', ...
    fullfile(projectRoot,'data','example_projects','multicompartment_head_project.mat'));
```

## Important notes

- Large `.mat` example projects under `example_projects/` are shipped in git (tens of MB each).
- Segmentation `.asc` files are **import inputs**, not loaded at startup.
- Do not commit sensitive patient data to `data/` in shared repos.

## Developer guidance

- Ship new examples with small assets under `data/` and document paths in `+examples` READMEs.
- Keep `import_segmentation.zef` paths consistent with folder layout (relative to project root or `data/`).
- Generated session logs live in `data/log/` (gitignored; created by `zef_start_log`).
