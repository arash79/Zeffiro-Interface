# Bundle / Result Schema

## Bundle (`bundle` variable in `*.mat`)

Required fields:

- `version` (double): schema version, currently `1`.
- `method_id` (string): inverse method identifier (e.g. `dspm`, `mne`,
  `eloreta`, `legacy_mne`).
- `method_info` (struct): output of `utilities.cluster.inverse_method_registry`.
- `method_params` (struct): method-specific parameters.
- `L` (double): processed lead field matrix.
- `procFile` (struct): output metadata from `zef_processLeadfields`.
- `source_direction_mode` (double): source orientation mode.
- `source_positions` (double): source positions for active interpolation set.
- `F` (double): measurement matrix (`n_sensors x n_frames`).
- `number_of_frames` (double): number of reconstruction frames.
- `use_gpu` (logical): GPU enable flag.
- `gpu_count` (double): available GPU count.
- `normalize_data` (double): normalization mode from `zef`.
- `common_inverse_parameters` (struct): shared inverse parameters copied from
  `inverse.CommonInverseParameters`.

Optional fields:

- `legacy_zef` (struct): full `zef` shim for legacy `evalin('base',...)` paths.

## Result (`result` variable in `*.mat`)

Produced by `utilities.cluster.run_inverse_job`.

- `success` (logical)
- `error` (char/string): stack trace on failure.
- `executionTime` (double)
- `maxNumCompThreads` (double)
- `method_id` (string)
- `reconstruction` (method-dependent array/cell)
- `reconstruction_information` (struct)
- `z_inverse` (raw inverse output before final merge)
- `profilerInfo` (optional, when profiler enabled)
