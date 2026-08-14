# `+environment` — FreeSurfer env from MATLAB

`run` cannot call `mri_mc` until the MATLAB process has the same environment a FreeSurfer shell would. This folder does that mutation, then checks that the binaries exist. It is not a GUI tool.

```matlab
utilities.fs2zef.environment.setup_freesurfer_env(getenv("FREESURFER_HOME"));
report = utilities.fs2zef.environment.validate_environment();
if ~report.valid
    error("%s", strjoin(report.errors, newline));
end
```

`setup_freesurfer_env(FREESURFER_HOME)` sets `FREESURFER_HOME`, `FSFAST_HOME`, `SUBJECTS_DIR` (if empty), `FUNCTIONALS_DIR`, MNI/FSL-related vars, and prepends `bin/` to `PATH`. Optional `fs_override` (default true) fills defaults when a variable is unset.

`validate_environment` returns `report.valid`, `report.errors`, `report.warnings` after checking those binaries (`mri_mc`, `mri_segstats`, `mris_convert`) and directories. `run` calls setup then validate and errors `fs2zef:InvalidEnvironment` if `valid` is false.

Side effect: `setenv` / `PATH` mutation in the MATLAB process for the rest of the session. Parent: [`../README.md`](../README.md).
