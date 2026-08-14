# `data/log`

Runtime logs from `zef_start_log` (called at the end of `zeffiro_interface`). Each file is `zeffiro_interface_<n>.log`; the stem is `zeffiro_log_file_name` in `profile/zeffiro_interface.ini` (default `zeffiro_interface`). When the file count exceeds `max_n_log_files` (default 100), the oldest are deleted.

Logging is on when `use_log` is 1 in that INI (or the matching `zef` field). **Settings → System settings (zeffiro_interface.ini)** edits those rows.

This folder is not source and is not on the MATLAB path. Safe to delete; Zeffiro recreates it when logging is on. Do not commit machine-specific logs. Parent: [`../README.md`](../README.md).
