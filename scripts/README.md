# scripts

## Folder purpose

Maintainer utilities that are **not** part of the Zeffiro MATLAB runtime path. Use this area for repo hygiene, mesh QA, and contribution notes — not for inverse/forward solvers.

## Main contents

| Item | Role |
|------|------|
| `validate_stl_manifold.py` | Binary STL watertight / non-manifold edge checker |
| `run_tests_batch.m` | Headless `tests` package run (`matlab -batch`) |
| `gui_responsiveness_probe.m` | Times nodisplay startup and a programmatic resize loop |
| `README.md` | This file |

Contribution guidelines live at the repository root: [`CONTRIBUTING.md`](../CONTRIBUTING.md). Developer placement rules: [`docs/developer-guide.md`](../docs/developer-guide.md).

## Code functionality

### `validate_stl_manifold.py`

1. Accepts one or more STL files or directories.
2. Reads binary STL triangles, welds vertices, counts boundary and non-manifold edges.
3. Prints whether each mesh looks watertight (`OK`) or open/non-manifold.

No MATLAB callers; CLI only.

## Workflow context

| Path | Relationship |
|------|----------------|
| `data/` (repo root) | Runtime example projects, electrodes, logs |
| `src/mesh` | Production meshing — validate STLs **before** import when debugging geometry |

## Usage instructions

```bash
python3 scripts/validate_stl_manifold.py path/to/model.stl
python3 scripts/validate_stl_manifold.py data/itokawa_model/

matlab -batch "run('scripts/run_tests_batch.m')"
matlab -batch "run('scripts/gui_responsiveness_probe.m')"
```

Read contribution rules:

```bash
less CONTRIBUTING.md
```

## Important notes

- Requires a working Python 3; no project virtualenv is mandated.
- These tools are intentionally outside `zeffiro_interface` `addpath` logic.

## Developer guidance

- Keep runtime MATLAB code out of `scripts/`; put solvers under `src/` or packages.
- Pitfall: committing large regenerated logs or STL dumps here.
