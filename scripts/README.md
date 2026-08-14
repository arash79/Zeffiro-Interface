# scripts

Maintainer tools that are **not** added to the MATLAB path by `zeffiro_interface`. Runtime code lives under `src/`, `+core`, `+inverse`, `+utilities`, and `tools/plugins/`.

## Contents

| Item | Role |
|------|------|
| `CONTRIBUTING.md` | How to contribute to this tree. |
| `data/README.md` | Notes on script-related data assets. |
| `validate_stl_manifold.py` | Checks exported STL surfaces for manifold issues (used with SimNIBS/FreeSurfer mesh exports). |

## Usage

```bash
python3 scripts/validate_stl_manifold.py path/to/mesh.stl
```

MATLAB documentation (`help` blocks and folder `README.md` files) is maintained by reading the implementation, not by regenerating comments from a script.

## Notes

- Do not add this folder to the MATLAB path at startup.
- Do not commit generated cache (`__pycache__/`) or one-off header-rewriting helpers.
