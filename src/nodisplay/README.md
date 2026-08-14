# Headless extras (`src/nodisplay`)

`zef_start` runs `addpath(genpath(.../src/nodisplay))` when `zef.use_display` is 0 (`start_mode` `'nodisplay'`).

**There are no `.m` files here.** Headless behaviour is implemented in:

- `zeffiro_interface(..., 'start_mode', 'nodisplay')`
- `src/io/zef_save_nodisplay.m`
- Import/save branches that skip `uigetfile` when display is off
- Cluster workers (`+utilities/+cluster`) and Brainstorm batch (`+utilities/+brainstorm2zef`)

An empty `genpath` add is harmless. If you add nodisplay-only shims, put them here and list each file in this README. Do not duplicate `zef_save_nodisplay`; extend that file for new save variants.

```matlab
zef = zeffiro_interface('start_mode', 'nodisplay');
```
