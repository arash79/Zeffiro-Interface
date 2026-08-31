# external

## Folder purpose

Git submodule placeholders for optional third-party toolboxes. They are **not** on the default Zeffiro path. `zeffiro_setup` clones the names listed in `.gitmodules` into these folders and writes `src/app/zef_start_config.m` so a later `zeffiro_interface` session can `addpath` them.

## Main contents

| Folder | Typical use |
|--------|-------------|
| `CVX/` | Convex modeling; `cvx_startup.m`; ES Workbench `zef_cvx_*` |
| `SDPT3/`, `SeDuMi/` | CVX numeric backends (`cvx_solver('sdpt3')` / `'sedumi'`) |
| `OSQP/` | Optional OSQP MATLAB path; **no** first-party `osqp` wrapper today |
| `SESAME/` | Optional SESAME_core (`hyperprior`); GUI still uses `plugins/SESAME` |
| `fieldtrip/` | Optional MEG/EEG I/O; `ft_defaults.m` |
| `spm12/` | Optional SPM path; not used by mesh/lead-field/inverse cores |

Each child folder has a Zeffiro-integration `README.md`. Vendor manuals stay inside the cloned trees. Empty placeholders are expected until `zeffiro_setup` (or `git submodule update`) populates them. Submodule URLs and optional `startupscript` entries live in the repository-root `.gitmodules`.

## Code functionality

`zeffiro_setup` reads `.gitmodules`, clones missing submodules into these folders, and writes `src/app/zef_start_config.m` with `addpath` (and optional startup-script) lines. `zeffiro_interface` then runs that generated config so solvers that `which` CVX/OSQP/FieldTrip succeed. Empty placeholder directories are expected in a fresh clone; they are not vendor source until populated. Do not treat files that appear here after clone as first-party Zeffiro code.

## Workflow context

```
.gitmodule names
  → zeffiro_setup (clone + zef_start_config.m)
  → zeffiro_interface addpath
  → plugins/ZeffiroESWorkbench (CVX + SDPT3/SeDuMi)
  → plugins/SESAME (GUI; this tree optional)
  → optional FieldTrip / SPM user scripts
```

`zef_start_config` `addpath`s each cloned folder (not `genpath(external)`). Startup scripts run only when `.gitmodules` defines `startupscript` and the file exists (CVX, FieldTrip today).

## Usage instructions

```matlab
zeffiro_setup("submodules", "all");           % clone every named submodule
zeffiro_setup("submodules", "CVX");           % one package
zeffiro_setup("skip_submodules", true);       % rewrite config without git
```

## Important notes

- Do not `addpath(genpath('external'))` yourself; let `zef_start_config` do it.
- Vendor copies keep their original licenses.
- SESAME GUI remains `plugins/SESAME` (ships `inverse_SESAME.m`; submodule branch is `hyperprior`).
- Only CVX and FieldTrip define `startupscript` in `.gitmodules` today.

## Developer guidance

Add a new optional dependency by adding a submodule under `external/` and a matching `[submodule]` block in `.gitmodules`. Keep this README’s table in sync with those names.
