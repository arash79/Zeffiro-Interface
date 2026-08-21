# +utilities/+fs2zef/+environment

## Folder purpose

MATLAB-side FreeSurfer environment setup and validation before `fs2zef` shells out to `mri_mc` / `mri_segstats` / `mris_convert`.

## Main contents

| File | Role |
|------|------|
| `setup_freesurfer_env.m` | `setenv` / `PATH` using `FREESURFER_HOME` |
| `validate_environment.m` | Check required binaries and directories |

## Code functionality

`setup_freesurfer_env(FREESURFER_HOME)` mutates the process environment. `validate_environment` fails fast if tools/dirs are missing so `run` does not half-write outputs.

## Workflow context

Called early from `utilities.fs2zef.run` before `+scripts/makeParcellation.sh`.

## Usage instructions

```matlab
utilities.fs2zef.environment.setup_freesurfer_env(getenv('FREESURFER_HOME'));
ok = utilities.fs2zef.environment.validate_environment();
```

## Important notes

- Needs a real FreeSurfer installation; WSL/macOS path differences matter.
- `setup_freesurfer_env` modifies the environment of the current MATLAB process only; it does not install FreeSurfer or modify system-wide shell configuration.
- `validate_environment` is read-only and checks the configured FreeSurfer installation, required directories, and binaries.
- Does not install FreeSurfer — it only configures and validates the current MATLAB process.

## Developer guidance

- Keep binary name checks in sync with `makeParcellation.sh`.
- Pitfall: validating once then changing `PATH` in a shell outside MATLAB.
