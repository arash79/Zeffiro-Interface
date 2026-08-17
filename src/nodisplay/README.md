# src/nodisplay

## Folder purpose

Reserved path for **headless-only MATLAB shims** that should be on the path when Zeffiro runs without a display. `src/core/zef_start.m` calls `addpath(genpath(.../src/nodisplay))` when `zef.start_mode` is `'nodisplay'` (and display use is off). The directory currently contains **no `.m` files**; headless behavior is implemented in shared code with conditional branches.

## Main contents

| Item | Status |
|------|--------|
| Headless override `.m` files | **None** |
| This `README.md` | Documents why `genpath` still runs and where real nodisplay logic lives |

Actual nodisplay support lives elsewhere:

- Entry: `zeffiro_interface(..., 'start_mode', 'nodisplay')`
- Lifecycle: `src/core/zef_start.m` (skips GUI tools; still builds `zef`)
- IO: `src/io/zef_save_nodisplay.m` and import paths that avoid `uigetfile` / dialogs
- Batch / cluster: `+utilities/+cluster`, `+examples`, converter drivers

## Code functionality

With an empty folder, `addpath(genpath(...))` is a no-op aside from adding the directory itself. Intended future contents:

- Thin wrappers that replace GUI-only helpers (file pickers, waitbar UI, figure capture)
- Optional stubs for App Designer exports that must not be constructed headlessly

Do **not** move core inverse or mesh mathematics here — keep those under `src/mesh`, `src/forward`, `src/inverse`, and `+inverse`.

## Workflow context

Typical pipeline for cluster / CI / overnight jobs:

1. `zef = zeffiro_interface('start_mode', 'nodisplay');`
2. Load project or build mesh / lead field programmatically
3. Run `utilities.cluster.dispatch_inverse` or a plugin solver script
4. Save via nodisplay-safe IO

GUI startup (`zef_start` with display) never adds this path, so GUI-only helpers stay out of the way.

## Usage instructions

```matlab
zef = zeffiro_interface('start_mode', 'nodisplay');
% or after constructing zef manually:
% zef.start_mode = 'nodisplay'; zef = zef_start(zef);
```

Verify path membership when debugging:

```matlab
which zef_save_nodisplay -all
% expect src/io, not this folder
```

## Important notes

- Empty `genpath` is intentional and harmless.
- `use_display == 0` and `'nodisplay'` start mode are related but not identical — follow `zef_start` branches when changing behavior.
- Plugins that open `.mlapp` / GUIDE windows will fail headlessly; guard with `zef.use_display` or skip GUI start scripts in batch drivers.
- Do not document vendor `external/` toolboxes as nodisplay substitutes.

## Developer guidance

- If you need a display-free replacement for a GUI helper, add it here **and** list it in Main contents the same day.
- Prefer extending `zef_save_nodisplay` / existing IO conditionals over copying large GUI files into this folder.
- Add a `+tests` case that starts nodisplay and runs a tiny inverse when you introduce the first shim.
- Never put secrets, machine-local paths, or cluster credentials in this folder.
