# +utilities/+fs2zef/+environment

## Folder purpose

MATLAB-side FreeSurfer environment setup and validation before `fs2zef` shells out to `mri_mc` / `mri_segstats` / `mris_convert`.

## Main contents

| File | Role |
|------|------|
| `setup_freesurfer_env.m` | `setenv` / `PATH` using `FREESURFER_HOME`. Names it may set (besides `FREESURFER_HOME` itself) are listed by parent `utilities.fs2zef.FREESURFER_ENV_VARS`. |
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

- Needs a real FreeSurfer install; WSL/macOS path differences matter.
- Does not install FreeSurfer — only configures the current MATLAB process.

## Developer guidance

- Keep binary name checks in sync with `makeParcellation.sh`.
- Pitfall: validating once then changing `PATH` in a shell outside MATLAB.
