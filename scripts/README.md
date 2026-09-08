# scripts

## Folder purpose

Maintainer utilities that are **not** part of the Zeffiro MATLAB runtime path. Use this area for repo hygiene, mesh QA, and icon regeneration — not for inverse/forward solvers.

## Main contents

| Item | Role |
|------|------|
| `validate_stl_manifold.py` | Binary STL watertight / non-manifold edge checker |
| `run_tests_batch.m` | Headless `tests` package run (`matlab -batch`) |
| `gui_responsiveness_probe.m` | Times nodisplay startup and a programmatic resize loop |
| `refresh_zef_ui_icons.py` | Rasterize `assets/fig/ui/Zeffiro_Modern_Icons/svg_masters/*.svg` to `assets/fig/ui/*.png` |
| `README.md` | This file |

Contribution guidelines live at the repository root: [`CONTRIBUTING.md`](../CONTRIBUTING.md). Developer placement rules: [`docs/developer-guide.md`](../docs/developer-guide.md).

## Code functionality

### `validate_stl_manifold.py`

1. Accepts one or more STL files or directories.
2. Reads binary STL triangles, welds vertices, counts boundary and non-manifold edges.
3. Prints whether each mesh looks watertight (`OK`) or open/non-manifold.

No MATLAB callers; CLI only.

### `refresh_zef_ui_icons.py`

Regenerates square PNG icons from the SVG masters. Optional integer argument is the pixel size (default 128). Requires `svglib` / `reportlab` (`pip install --user svglib`) and macOS `sips` to rasterize intermediate PDFs. Do not commit those PDFs; they are gitignored.

## Workflow context

| Path | Relationship |
|------|----------------|
| `data/` (repo root) | Runtime example projects, electrodes, logs |
| `src/mesh` | Production meshing — validate STLs **before** import when debugging geometry |
| `src/gui/chrome/zef_ui_icons.m` | Consumes the PNG set produced by `refresh_zef_ui_icons.py` |

## Usage instructions

```bash
python3 scripts/validate_stl_manifold.py path/to/model.stl
python3 scripts/validate_stl_manifold.py data/itokawa_model/

python3 scripts/refresh_zef_ui_icons.py 128

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
- Do not add machine-specific `cd('/Users/...')` wrappers here.

## Developer guidance

- Keep runtime MATLAB code out of `scripts/`; put solvers under `src/` or packages.
- Pitfall: committing large regenerated logs, STL dumps, or GUI screenshot trees.
