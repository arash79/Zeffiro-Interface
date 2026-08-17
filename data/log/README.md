# data/log

## Folder purpose

Default directory for **session log files** written at startup, plus local **UI QA scripts and screenshots** used during GUI/layout work. Runtime logging is configured from `zef_start_log`; the PNG/`.m` helpers here are developer utilities, not product features.

## Main contents

| Kind | Examples | Role |
|------|----------|------|
| Session logs | `zeffiro_interface_*.log` | Text logs from GUI / nodisplay sessions |
| UI snapshots | `ui_*.png` | Captures of tools (menu, mesh, figure, plugins, …) |
| Layout QA images | `inspect_*.png` | Resize / aspect-ratio inspection dumps |
| QA scripts | `capture_zef_ui.m`, `inspect_ui_layouts.m`, `inspect_figure_tool_sizes.m`, `exercise_figure_callbacks.m` | Drive capture / callback smoke tests |

Counts fluctuate; old logs may be deleted safely.

## Code functionality

- **Logs:** appended by the logging path started from `src/core` (see `zef_start_log` / related). Content includes warnings, task messages, and path noise depending on verbosity.
- **QA scripts:** expect a running Zeffiro GUI session (`zef` with tool handles). They call helpers such as `zef_capture_ui` / layout inspectors and write PNGs into this folder.

These scripts are **not** registered in profile plugin INIs.

## Workflow context

```
zef_start → zef_start_log → data/log/zeffiro_interface_<n>.log
GUI layout work → inspect_*.m / capture_*.m → PNG evidence in this folder
```

Related: `src/gui/helpers/zef_capture_ui.m`, layout helpers `zef_layout_*`, `zef_ui_*`.

## Usage instructions

Open the newest log after a crash:

```matlab
% from a shell
ls -lt data/log/zeffiro_interface_*.log | head
```

Run UI capture only with a live session and display:

```matlab
% after zeffiro_interface GUI start
run(fullfile(zef.program_path, 'data', 'log', 'capture_zef_ui.m'));
```

## Important notes

- Logs and PNGs often contain machine-local paths — avoid committing patient-identifying paths.
- Safe to delete `*.log` and stale `inspect_*.png` / `ui_*.png` when cleaning a clone.
- QA scripts may resize windows aggressively; save work before running size sweeps.

## Developer guidance

- Keep product logging code in `src/core` / `src/io`; keep one-off capture scripts here or under `scripts/`.
- If promoting a capture helper to supported API, move it to `src/gui/helpers` and document arguments.
- Pitfall: committing hundreds of log rotations — prefer `.gitignore` patterns for `zeffiro_interface_*.log` when policy allows.
