# External Dependencies

This directory holds **third-party libraries and solvers** used by Zeffiro Interface. They are integrated as **Git submodules**: each dependency lives in its own repository and is checked out here when you install or update the project. The submodule list and URLs are defined in the root [`.gitmodules`](../.gitmodules) file.

**Note:** The code inside each submodule directory is maintained by its respective upstream project. For documentation, licensing, and implementation details of a given library, refer to that project’s repository and documentation.

---

## Contents Overview

| Submodule   | Path              | Purpose in Zeffiro Interface |
|------------|-------------------|------------------------------|
| **CVX**    | `external/CVX`    | Convex optimization modeling; used with SDPT3/SeDuMi for ES (electrical stimulation) and related solvers. |
| **SDPT3**  | `external/SDPT3`  | Semidefinite-quadratic-linear program solver; used as a backend for CVX in ES optimization. |
| **SeDuMi** | `external/SeDuMi` | Semidefinite programming solver; alternative backend for CVX in ES optimization. |
| **OSQP**   | `external/OSQP`  | Operator Splitting Quadratic Program solver; used for quadratic programs in ES optimization. |
| **SESAME** | `external/SESAME`| SESAME (Sequential Semi-Analytical MEG/EEG) source reconstruction; used by the SESAME plugin. |
| **FieldTrip** | `external/fieldtrip` | FieldTrip toolbox; used for M/EEG analysis and data structures (e.g. in Duneuro2Zef utilities). |
| **SPM12**  | `external/spm12` | Statistical Parametric Mapping; used for neuroimaging and segmentation-related workflows. |

Submodules that require a startup script (e.g. to set the MATLAB path or defaults) are configured in `.gitmodules` and are run automatically by Zeffiro after `zeffiro_setup`:

- **CVX:** `external/CVX/cvx_startup.m`
- **FieldTrip:** `external/fieldtrip/ft_defaults.m`

Repository URLs (as in [`.gitmodules`](../.gitmodules)):

- **CVX:** <https://github.com/SeSodesa/CVX> (branch: `15-gitmodules-to-use-https`)
- **SDPT3:** <https://github.com/sqlp/sdpt3> (branch: `master`)
- **SeDuMi:** <https://github.com/sqlp/sedumi> (branch: `master`)
- **OSQP:** <https://github.com/osqp/osqp-matlab> (branch: `master`)
- **SESAME:** <https://github.com/i-am-sorri/SESAME_core> (branch: `hyperprior`)
- **FieldTrip:** <https://github.com/fieldtrip/fieldtrip> (branch: `release`)
- **SPM12:** <https://github.com/spm/spm12> (branch: `master`)

---

## Installation

### Option 1: Clone with submodules (recommended)

Use a recursive clone so submodules are fetched in one step.

- **Git 2.13+**
  ```bash
  git clone --recurse-submodules https://github.com/sampsapursiainen/zeffiro_interface.git
  ```

- **Git 1.6.5–2.12**
  ```bash
  git clone --recursive https://github.com/sampsapursiainen/zeffiro_interface.git
  ```

Then start Zeffiro Interface (e.g. run `zeffiro_interface` in MATLAB). If your clone did not use `--recurse-submodules`/`--recursive`, run `zeffiro_setup` in MATLAB to fetch and initialize submodules (see Option 2).

### Option 2: Clone without submodules, then run setup

If you cloned without recursion (e.g. from an archive or without `--recurse-submodules`), open MATLAB in the project root and run:

```matlab
zeffiro_setup
```

This will:

1. Read [`.gitmodules`](../.gitmodules) and clone/update the listed submodules into `external/`.
2. Generate or update the startup configuration so that the paths and startup scripts of these dependencies are applied when Zeffiro Interface starts.

To install only a subset of submodules, use the `submodules` option, e.g.:

```matlab
zeffiro_setup("submodules", ["CVX", "SDPT3", "SeDuMi"])
```

Use `"all"` to install every submodule listed in `.gitmodules`.

---

## Adding a New External Submodule

If you add a new Git submodule under `external/` for use with Zeffiro (e.g. for a plugin), you must **allow it in the project’s [`.gitignore`](../.gitignore)**. The repository intentionally ignores the contents of `external/` by default and then un-ignores each known submodule path (e.g. `!external/CVX`). Add a similar line for your new submodule path so that Git tracks it.

---

## Summary

- **Purpose:** Central place for third-party solvers and toolboxes (optimization, source reconstruction, M/EEG, neuroimaging).
- **Management:** Submodules are defined in [`.gitmodules`](../.gitmodules) and installed/updated via `zeffiro_setup` or a recursive clone.
- **Documentation:** For each library’s API, options, and internals, see the corresponding upstream repository and docs.
