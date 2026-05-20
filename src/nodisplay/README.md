# src/nodisplay

## Folder purpose

**Placeholder path** for headless-specific MATLAB sources. `zef_start.m` executes `addpath(genpath(.../src/nodisplay))` when `zef.use_display == 0`, but the directory currently has **no `.m` files**.

## Main contents

- `README.md` only

## Code functionality

Headless behavior is implemented elsewhere:
- `zeffiro_interface(..., 'start_mode', 'nodisplay')`
- `src/io/zef_save_nodisplay.m`
- Import/save branches that skip `uigetfile` when display off
- `+utilities/+brainstorm2zef/run.m` and examples using nodisplay startup

## Workflow context

Cluster workers and batch examples set nodisplay; they rely on `src/io` and `+utilities/+cluster`, not this folder.

## Usage instructions

```matlab
zef = zeffiro_interface('start_mode', 'nodisplay');
```

## Important notes

- Empty `genpath` add is harmless — reserved for future nodisplay-only shims.
- Do not move core logic here without updating `zef_start` documentation.

## Developer guidance

- If adding nodisplay overrides, place them here and document each function in this README.
- Avoid duplicating `zef_save_nodisplay` — extend that file instead for save variants.
