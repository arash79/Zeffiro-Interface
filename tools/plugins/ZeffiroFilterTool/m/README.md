## Folder purpose

Start script, pipeline runner, and GUI callbacks for **Forward tools → Filter tool**. Stage implementations live in `filter_bank/` (keep their `Description:` / `Input:` / `Output:` help tags — init and Add parse `help()`).

## Main contents

| File | Role |
|------|------|
| `zef_filter_tool.m` | INI callback; opens App Designer window and wires buttons |
| `zef_init_filter_tool.m` | Builds `filter_file_list` from `filter_bank/*.m` via `Description:` |
| `zef_update_filter_tool.m` | Refresh pipeline list, parameter table, tag, sampling rate, zoom |
| `zef_filter_raw_data.m` | Run all pipeline stages on `raw_data` → `processed_data` |
| `zef_add_filter_item.m` / `zef_delete_filter_item.m` | Append / compact `filter_pipeline` |
| `zef_move_up_filter_item.m` / `zef_move_down_filter_item.m` | Reorder stages |
| `zef_import_raw_data.m` | `.mat`/`.dat` → `raw_data` |
| `zef_filter_plot_data.m` / `zef_filter_schroll_bar.m` | Plot and time slider |
| `zef_filter_save_as.m` / `zef_filter_load.m` | Pipeline + raw `.mat` |
| `zef_filter_save_processed_data_as.m` | `processed_data` only |
| `zef_filter_reset.m` | Clear pipeline/epoch/lists (not `raw_data`) |
| `zef_load_epoch_points.m` | Load epoch-point `.mat` (also resets pipeline) |
| `zef_filter_substitute_*.m` | Copy processed/raw/measurement/noise between fields |

## Code functionality

Pipeline stages are ordered filters/epoching steps applied to `raw_data`. Inverse methods still read `zef.measurements`; Substitute buttons copy `processed_data` onto measurements / raw / noise as wired.

## Workflow context

Forward tools → Filter tool. Parent README is the user manual. Stages: `filter_bank/README.md`. Typical path: import raw → build pipeline → run → Substitute into `measurements` before inverse.

## Usage instructions

Open from the menu, Add stages, set parameters, run filtering, then Substitute as needed. Save/load pipeline via the tool buttons.

## Important notes

- Substitute wiring is swapped vs filenames: `h_filter_substitute_raw_data` calls `zef_filter_substitute_measurement_data` (writes `raw_data`); `h_filter_substitute_measurement_data` calls `zef_filter_substitute_raw_data` (writes `measurements`).
- `zef_filter_save_as` copies `filter_name_list` into `zef_data.filter_file_list`.
- Load/epoch-point dialogs store the pick on `zef_data.file` then `load` `zef.file`.

## Developer guidance

New stages go in `filter_bank/` with required help tags. Do not hard-code the stage list in init. When changing Substitute buttons, update both handle names and the parent README.
