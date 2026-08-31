# `utilities.duneuro2zef` — Duneuro export → Zeffiro

## Folder purpose

Convert a Duneuro/FieldTrip-style export folder into Zeffiro tetra mesh, source space, sensors, lead fields, and measurements. Two layers: **file conversion** (`run`) and optional **session import** (`import_duneuro_project`).

## Main contents

| Entry | Role |
|-------|------|
| `run.m` / `Duneuro2Zeffiro_convert.m` | Convert files → `output_folder` `.mat`s |
| `Duneuro2Zeffiro_settings.m` | Interactive / default settings overlay used by the convert path |
| `import_duneuro_project.m` | Conversion + `zef_import_segmentation` on bundled `.zef` |
| `convert_mesh.m` | Hexa → tetra (`zef_hexa_to_tetra`) |
| `process_source_space` / `process_sensors` / `process_eeg_data` / `process_meg_data` | Modality processors |
| `process_resection_points.m` | Optional `resection_points.dat` → Zeffiro resection coords |
| `EEG_to_databank` / `MEG_to_databank` | Data-bank population |
| `get_default_config` / `validate_config` / `find_files` | Config helpers |
| `Duneuro2Zeffiro_import.zef` | Import recipe (hard-codes `data/converted/` style paths) |

## Code functionality

**Expected inputs (defaults):** `mesh.mat` (hex `elements`/`nodes`), `sp_vol_rgv_N*.mat`, `sensors.mat`, `LF_EEG.mat`/`LF_MEG.mat`, `spikeAvg*.mat`, optional `resection_points.dat`.

**Outputs:** `tetra_mesh.mat`, `source_space.mat`, `L_*.mat`, measurements/sensors mats under `config.output_folder`.

Relative output paths resolve from **`pwd`**. Bundled `.zef` expects project-root layout.

## Workflow context

```
Duneuro export → utilities.duneuro2zef.run → data/converted
  → import_duneuro_project / zef_import_segmentation → live zef
```

## Usage instructions

```matlab
config = utilities.duneuro2zef.get_default_config();
config.input_folder = 'my_duneuro_export';
config.output_folder = 'data/converted';
results = utilities.duneuro2zef.run(config);

zef = zeffiro_interface('start_mode', 'nodisplay');
assignin('base', 'zef', zef);
results = utilities.duneuro2zef.import_duneuro_project(config, true);
```

## Important notes

- Session import requires `zef` already in base for auto-detect paths.
- `Duneuro2Zeffiro_convert` skips work if key outputs already exist.
- Measurement structs default to FieldTrip-like `'avg'` field.

## Developer guidance

- Keep `.zef` hard-coded folder names documented when changing defaults.
- Extend `find_files` patterns carefully — Duneuro dumps vary by site.
- Prefer `run` for CI (no GUI); use import only when a session is needed.
