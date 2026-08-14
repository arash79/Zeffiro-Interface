# m

Start script, pipeline runner, and GUI callbacks for the Filter tool. Stage implementations: `filter_bank/` (keep their `Description:` / `Input:` / `Output:` lines — `zef_init_filter_tool` and `zef_add_filter_item` parse `help()`). User manual: parent README.

| File | Role |
|------|------|
| `zef_filter_tool` | INI callback (Forward tools → Filter tool). Opens the App Designer window and wires buttons. |
| `zef_init_filter_tool` | Builds `filter_file_list` from `filter_bank/*.m` via `Description:` |
| `zef_update_filter_tool` | Refresh pipeline list, parameter table, tag, sampling rate, zoom |
| `zef_filter_raw_data` | Run **all** pipeline stages on `raw_data` → `processed_data` |
| `zef_add_filter_item` / `zef_delete_filter_item` | Append / compact `filter_pipeline` |
| `zef_move_up_filter_item` / `zef_move_down_filter_item` | Reorder selected stages to front / end |
| `zef_import_raw_data` | `.mat`/`.dat` → `raw_data` |
| `zef_filter_plot_data` / `zef_filter_schroll_bar` | Plot on `h_axes1` and time slider |
| `zef_filter_save_as` / `zef_filter_load` | Pipeline + raw `.mat` |
| `zef_filter_save_processed_data_as` | `processed_data` only |
| `zef_filter_reset` | Clear pipeline/epoch/lists (not `raw_data`) |
| `zef_load_epoch_points` | Load epoch-point `.mat` (also resets the pipeline) |

Substitute wiring in `zef_filter_tool` is swapped vs filenames: `h_filter_substitute_raw_data` calls `zef_filter_substitute_measurement_data` (writes `raw_data`); `h_filter_substitute_measurement_data` calls `zef_filter_substitute_raw_data` (writes `measurements`). `zef_filter_save_as` copies `filter_name_list` into `zef_data.filter_file_list`. Load/epoch-point dialogs store the pick on `zef_data.file` then `load` `zef.file`.
