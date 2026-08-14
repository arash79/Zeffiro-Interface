# `utilities.duneuro2zef` — Duneuro export folder → Zeffiro `.mat` + databank

Converts a Duneuro/FieldTrip-style export directory into Zeffiro tetra mesh, source space, sensors, lead fields, and measurements. Two layers:

1. **File conversion** — `run(config)` writes `config.output_folder` `.mat` files (no Zeffiro session required).
2. **Session import** — `import_duneuro_project(config)` then runs `zef_import_segmentation` on bundled `Duneuro2Zeffiro_import.zef` **if** `zef` already exists in the base workspace.

## What must exist on disk

Defaults from `get_default_config` (override `config.input_folder` / filenames):

| Config field | Default pattern | Contents expected |
|--------------|-----------------|-------------------|
| `files.mesh` | `mesh.mat` | Hexahedral `elements` (N×8) and `nodes` (N×3), optional `labels` |
| `files.source_space` | `sp_vol_rgv_N*.mat` | Source positions; `source_space.priority` `'smallest'` / `'largest'` / pattern |
| `files.sensors` | `sensors.mat` | Channel geometry |
| `files.leadfield_eeg` / `_meg` | `LF_EEG.mat` / `LF_MEG.mat` | Lead-field matrices |
| `files.measurements_eeg` / `_meg` | `spikeAvgEEG.mat` / `spikeAvgMEG.mat` | FieldTrip-like structs; measurement field default `'avg'` |
| `files.resection_points` | `resection_points.dat` | Optional |

`validate_config` requires `input_folder` to exist when conversion runs. Output folder is created as needed. **Relative output paths are resolved from `pwd`**, not from this package directory. The bundled `.zef` hard-codes `foldername,data/converted/` — stay in the project root (or match that layout).

## Public entries

```matlab
config = utilities.duneuro2zef.get_default_config();
config.input_folder = 'my_duneuro_export';
config.output_folder = 'data/converted';

% Files only:
results = utilities.duneuro2zef.run(config);

% Files + import into an already-running Zeffiro session:
zef = zeffiro_interface('start_mode', 'nodisplay');  % must assign to base for auto-detect
assignin('base', 'zef', zef);
results = utilities.duneuro2zef.import_duneuro_project(config, true);
```

`Duneuro2Zeffiro_convert` is the same conversion as `run`, used as a **script line** inside `Duneuro2Zeffiro_import.zef`. If key outputs already exist, it skips reconversion.

`import_duneuro_project(config, false)` converts only. If the second argument is omitted, import runs only when `exist('zef','var')` in base.

## Config flags (`get_default_config`)

| Flag | Default | Effect |
|------|---------|--------|
| `process_eeg` / `process_meg` | true | Convert LF, measurements, sensors |
| `process_resection_points` | true | Optional; failure is a **warning** |
| `invert_domain_labels` | true | `labels = max(labels)+1-labels` (Duneuro vs Zeffiro numbering) |
| `continue_on_error` | false | Stop vs collect errors |
| `verbose` | true | |
| `domain_labels.brain` | `2` | Used when saving `brain_ind` |
| `eeg.channel_indices` | `[302:358, inf]` | `inf` means end of channel list |
| `eeg.channel_path` | `{'cfg','previous','previous','channel'}` | FieldTrip nested path |
| `meg.max_channels` | 274 | Magnetometers first if `use_magnetometers` |
| `mesh.save_brain_ind` | true | Extra variable in `tetra_mesh.mat` |

## Output files (`config.output.*`)

Written under `output_folder`:

| File | From |
|------|------|
| `tetra_mesh.mat` | Hex → tet via `zef_hexa_to_tetra`; variables `tetra`, `domain_labels`, `nodes`, optional `brain_ind` |
| `source_space.mat` | Source positions |
| `resection_points.mat` | Optional |
| `L_EEG.mat` / `L_MEG.mat` | Lead fields |
| `EEG_measurements.mat` / `MEG_measurements.mat` | |
| `EEG_sensors.mat` / `MEG_sensors.mat` | |

## Coordinate / mesh conventions

- Input mesh **must** be hexahedral (8 nodes per element). Tet input fails `convert_mesh`.
- Nodes are copied as stored (no unit conversion in `convert_mesh`).
- Domain labels may be inverted so Zeffiro compartment indices match the bundled `.zef` names (Scalp … White matter).

## Import into Zeffiro (`Duneuro2Zeffiro_import.zef`)

Line order (implementation):

1. Script `Duneuro2Zeffiro_convert`
2. Sensors: Coils (`MEG_sensors.mat`), Electrodes (`EEG_sensors.mat`)
3. Structs: `tetra_mesh`, `source_space`, `L_MEG`, `MEG_measurements`, `resection_points`
4. Script `MEG_to_databank`
5. Structs: `L_EEG`, `EEG_measurements`
6. Script `EEG_to_databank`
7. Empty segmentation names: Scalp, Compact bone, Spongious bone, CSF, Grey matter, White matter
8. Script `Duneuro2Zeffiro_settings` — sets `source_direction_mode=1`, `inv_sampling_frequency=2400`, compartment source constraints, `zef_build_compartment_table`, downsampling / interpolation

`import_duneuro_project` sets `zef.file` / `zef.file_path` to that `.zef`, `zef.new_empty_project = 0`, then `zef_import_segmentation`. Databank helpers also `assignin('base','zef',...)`.

Alternatively, with Zeffiro already open: **Import → Import data to project** pointing at this `.zef`, from a cwd where `data/converted/` exists. (The live labels are assigned in `zef_menu_tool.m`; the App Designer defaults still say “Import new segmentation from folder”.)

## Gaps

- `Duneuro2Zeffiro_import.zef` paths are not rewritten from `config.output_folder`. Custom output directories require editing the `.zef` or matching `data/converted/`.
- `run` initializes databank only if `zef` is already in base; conversion itself does not start Zeffiro.
- EEG channel index default `[302:358, inf]` is dataset-specific, not a universal 10–20 map.
