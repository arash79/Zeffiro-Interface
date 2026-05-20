# documentation/fonts

## Purpose of this folder

LaTeX and Markdown technical documentation sources.

## Contents

Other files:
- `Erewhon-Bold.otf`
- `Erewhon-BoldItalic.otf`
- `Erewhon-BoldSlanted.otf`
- `Erewhon-Italic.otf`
- `Erewhon-Regular.otf`
- `Erewhon-RegularSlanted.otf`
- `JuliaMono-Black.ttf`
- `JuliaMono-BlackItalic.ttf`
- `JuliaMono-Bold.ttf`
- `JuliaMono-BoldItalic.ttf`
- `JuliaMono-BoldLatin.ttf`
- `JuliaMono-ExtraBold.ttf`
- `JuliaMono-ExtraBoldItalic.ttf`
- `JuliaMono-Light.ttf`
- `JuliaMono-LightItalic.ttf`
- `JuliaMono-Medium.ttf`
- `JuliaMono-MediumItalic.ttf`
- `JuliaMono-Regular.ttf`
- `JuliaMono-RegularItalic.ttf`
- `JuliaMono-RegularLatin.ttf`
- `JuliaMono-SemiBold.ttf`
- `JuliaMono-SemiBoldItalic.ttf`

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

No dedicated menu item in this folder; functionality is reached through parent tools, menus, or `zef_*` orchestration.

## Programmatic usage

Add the project root to the MATLAB path (`zeffiro_interface` or `addpath(genpath(projectRoot))`), then call functions in child folders using package or `zef_*` names as listed under Contents.

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
