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
| `log/` | Rotating `zeffiro_interface_*.log` files from `zef_start_log` |
| `media/` | Screenshots and demo `.png` / `.avi` for documentation |
| `Sub01FG.mat`, `Sub01FG_Mesh_Anisotropic.mat` | Large sample subject meshes (optional downloads) |
| `default_project.mat` | **Expected** warm-start project — often absent in git clone |

## Code functionality

**Startup load** (if file exists):
```matlab
zef = zef_load(zef, 'default_project.mat', zef.data_path);
```

**Import segmentation:** GUI or CLI passes path to `import_segmentation.zef`; manifest lists relative paths into `segmentations/multicompartment_head_project/*.asc`.

**Logs:** `zef_start_log` creates `data/log/` and prunes old files per `max_n_log_files` in system INI.

**Examples** write outputs here: e.g. `+examples/+forward/lead_field_example.mat` → `data/lead_field_example.mat`.

## Workflow context

| Consumer | Path used |
|----------|-----------|
| `zeffiro_interface` CLI args | Relative paths with no directory → `data/` (not `data/example_projects/` or `data/segmentations/`) |
| `+examples/+importing` | Hard-coded `scripts/scripts_for_importing/...`; if missing, pass `data/segmentations/.../import_segmentation.zef` |
| `+core` electrode import | User-selected files; sample caps in `electrodes/` |
| `profile/zeffiro_interface.ini` | `save_file_path = ./data/` |

Not on MATLAB path as code — data only.

## Usage instructions

```matlab
% Import bundled head segmentation (full path; relative would look under data/)
zef = zeffiro_interface('import_to_new_project', ...
    fullfile(projectRoot,'data','segmentations','multicompartment_head_project','import_segmentation.zef'));

% Open example project (open_project is a single path; no directory → data/)
zef = zeffiro_interface('open_project', ...
    fullfile(projectRoot,'data','example_projects','multicompartment_head_project.mat'));
```

## Important notes

- Large `.mat` files may be gitignored or LFS — check repo before assuming presence.
- Segmentation `.asc` files are **import inputs**, not loaded at startup.
- `fs2zef.sh` in segmentation folder is a FreeSurfer conversion helper script.
- Do not commit sensitive patient data to `data/` in shared repos.

## Developer guidance

- Ship new examples with small assets under `data/` and document paths in `+examples` READMEs.
- Keep `import_segmentation.zef` paths consistent with folder layout (relative to project root or `data/`).
- Add `.gitignore` entries for generated logs and huge meshes in `data/log/` and root `data/*.mat` if needed.
