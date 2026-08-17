# scripts

## Folder purpose

Maintainer utilities that are **not** part of the Zeffiro MATLAB runtime path. Use this area for repo hygiene, mesh QA, contribution notes, and offline fixtures — not for inverse/forward solvers.

## Main contents

| Item | Role |
|------|------|
| `validate_stl_manifold.py` | Binary STL watertight / non-manifold edge checker |
| `CONTRIBUTING.md` | Contribution guidelines for this repository |
| `data/` | Offline fixtures (e.g. `SEP_synth_source_data.mat`) — see `data/README.md` |
| `README.md` | This file |

Note: older docs may mention `zeffiro_doc_pass.py`; that script is **not** present in the tree today. Do not assume automated README regeneration exists.

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
| `scripts/data/` | Offline experiment fixtures only |
| `src/mesh` | Production meshing — validate STLs **before** import when debugging geometry |

## Usage instructions

```bash
python3 scripts/validate_stl_manifold.py path/to/model.stl
python3 scripts/validate_stl_manifold.py data/itokawa_model/
```

Read contribution rules:

```bash
less scripts/CONTRIBUTING.md
```

## Important notes

- Requires a working Python 3; no project virtualenv is mandated.
- Do not confuse `scripts/data` with runtime `data/`.
- These tools are intentionally outside `zeffiro_interface` `addpath` logic.

## Developer guidance

- Keep runtime MATLAB code out of `scripts/`; put solvers under `src/` or packages.
- If restoring a documentation pass script, gate it behind explicit CLI flags and never overwrite carefully hand-written READMEs by default.
- Pitfall: committing large regenerated logs or STL dumps into `scripts/data`.
