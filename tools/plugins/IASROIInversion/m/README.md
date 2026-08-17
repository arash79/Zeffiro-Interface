## Folder purpose

MATLAB implementation for IAS ROI MAP: window open, ROI mode widgets, plotting helpers, and the restricted lead-field iteration. Parent folder README is the user manual.

## Main contents

| File | Role |
|------|------|
| `ias_map_estimation_roi.m` | INI callback (filename) |
| `zef_init_ias_roi.m` | Window + defaults; does not rebind Start |
| `zef_ias_map_estimation_roi_window.m` | GUIDE dump with live Start string |
| `zef_update_ias_roi.m` / `zef_switch_roi_mode.m` | Widgets / enable |
| `zef_iasroi_plot_roi.m` | Plot Sphere(s) |
| `zef_ias_iteration_roi.m` | Solver on disk |

## Code functionality

`zef_ias_iteration_roi` builds a ROI column mask from sphere / threshold / parcellation, runs IAS MAP on `L(:, roi_aux_ind)`, and returns `[z, rec_source]`. Init seeds `iasroi_*` from `inv_*` where applicable. Plot helpers draw on Figure-tool axes without writing reconstruction.

## Workflow context

Called from Inverse tools → IAS ROI Inversion. There is no `inverse.*Inverter` for this ROI variant. Full-volume IAS lives in `IASInversion` / `inverse.IASInverter`.

## Usage instructions

```matlab
zef = ias_map_estimation_roi(zef);   % or menu
% After widgets are set:
[zef.reconstruction, zef.iasroi_rec_source] = zef_ias_iteration_roi([]);
```

Prefer calling `zef_ias_iteration_roi` by its real name; the fig Start string still says `ias_iteration_roi`.

## Important notes

- Filename `ias_map_estimation_roi.m` vs in-file `ias_map_estimation` — INI uses the filename.
- Live Start: `ias_iteration_roi([])` — no such `.m`; solver is `zef_ias_iteration_roi`.
- `zef_iasroi_plot_roi` with no args uses `eval('base','zef')` as written (not `evalin`).

## Developer guidance

Patch Start in the window / init to call `zef_ias_iteration_roi`. Align the start-file function name with the filename before relying on `nargin`/`nargout` patterns. Do not add an `inverse.*Inverter` here unless registering a new ROI method in the class registry.
