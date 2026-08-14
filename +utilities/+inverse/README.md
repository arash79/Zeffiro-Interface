# `utilities.inverse` — time-frame loop for class inverters

Single function: `run_frame_loop`. `dispatch_inverse` (and therefore `zef_inverse_run`) uses it for every `execution_kind == "class"` method. Do not duplicate this loop in plugins.

```matlab
[z_inverse, MethodClassObj] = utilities.inverse.run_frame_loop( ...
    zef, MethodClassObj, L, procFile, ...
    source_direction_mode, source_positions, ...
    waitbar_handle, waitbar_title);
```

## Arguments

| Argument | Role |
|----------|------|
| `zef` | Must supply measurements via `zef_getFilteredDataClassObj` (`inv_data_mode`). Cluster shim sets `inv_data_mode='raw'` and `measurements = bundle.F` |
| `MethodClassObj` | Any `inverse.CommonInverseParameters.isAnInverter` object |
| `L`, `procFile`, `source_direction_mode`, `source_positions` | From `zef_processLeadfields` / the bundle |
| `waitbar_handle`, `waitbar_title` | Progress + ETA |

## Behaviour

1. `z_inverse = cell(1, MethodClassObj.number_of_frames)`.
2. Errors `EmptyData` if filtered data is empty; `FrameCountExceedsData` if `number_of_frames` > columns of `f_data`.
3. If the class defines `initialize`: uses `zef.inverse_initialization_measurements` when that field is non-empty, otherwise concatenates all frame time-steps.
4. If `precompute` exists: tries `precompute(L, procFile)`, falls back to `precompute(L)` only on “too many inputs”.
5. Each frame: `zef_getTimeStepClassObj` → optional `gpuArray` when `zef.use_gpu && zef.gpu_count > 0` → `invert(..., "use_gpu", ..., "normalize_data", zef.normalize_data)`.

Returns the cell of source vectors and the (possibly updated) inverter object. Does not write `zef.reconstruction`; `dispatch_inverse` / `zef_postProcessInverseClassObj` do that.
