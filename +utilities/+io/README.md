# +utilities/+io

## Folder purpose

Small path / file / numeric I/O helpers used by converters, cluster code, and import utilities. Not the project `.mat` save/load API (`src/io`).

## Main contents

| File | Role |
|------|------|
| `abspath.m` | Resolve absolute paths |
| `float_is_int.m` | Test whether a float is an integer value |
| `is_eof.m` | EOF helper for file IDs |
| `read_gitmodules.m` | Parse `.gitmodules` for submodule metadata |
| `reconstruction_from_edf_fn.m` | Build / locate reconstruction naming from EDF-related filenames |

## Code functionality

Pure helpers: string/path and lightweight parsing. Call as `utilities.io.<name>(...)`.

## Workflow context

Used by package converters and tooling that must not depend on GUI `uigetfile`. Session persistence remains `src/io`.

## Usage instructions

```matlab
p = utilities.io.abspath('data/example_projects');
tf = utilities.io.float_is_int(3.0);
```

## Important notes

- Does not read electrode `.dat` (see `core.io.electrodes`).
- `read_gitmodules` expects the repo-root `.gitmodules` format.

## Developer guidance

- Keep this package free of `zef` mutation.
- Pitfall: using `abspath` with assumptions about `pwd` vs `zef.program_path`.
