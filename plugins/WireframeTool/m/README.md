## Folder purpose

GPU-ToRRe microwave **printable wireframe** tool (not EEG inverse). Builds a wireframe surface from tetrahedral domains and permittivity mixing. Asteroid profiles: Multi tools → Wireframe creator tool.

## Main contents

| File | Role |
|------|------|
| `zef_wireframe_creator_start.m` | INI / MATLAB start; Create → filling then `wireframe(...)`; Plot → `zef_wireframe_plot` |
| `wireframe.m` | Surface extraction from tets + filling |
| `zef_wireframe_filling_vec.m` / `zef_wireframe_permittivity_vec.m` | Maxwell–Garnett mixing from `epsilon` |
| `zef_wireframe_plot.m` | Phong-lit gray surface |

Layout: `../mlapp/` (`zef_wireframe_creator_app.mlapp`). Parent README documents widgets.

## Code functionality

Needs `zef.tetra`, `zef.nodes`, `zef.domain_labels`, `zef.epsilon` (permittivity from parameter profile / NSE-style fields, not `zef.sigma`). Filling/permittivity vectors mix relative permittivity; `wireframe` extracts a printable surface. Per-domain branch indexes undeclared `tetrahedra(:,5)` — treat that path as incomplete unless a 5-column tet array is provided.

## Workflow context

Default and asteroid Multi tools menus. Separate from EEG/MEG inverse plugins.

## Usage instructions

```matlab
zef = zef_wireframe_creator_start(zef);
% Create / Plot from the window, or call helpers after widgets exist
```

## Important notes

- `zef_wireframe_plot` declared arguments are unused; needs `h_t` / `h_a` in the **caller** workspace.
- Uses `epsilon`, not conductivity `sigma`.
- Incomplete tet-column path in `wireframe.m` as documented above.

## Developer guidance

Fix the 5-column tet assumption or gate that branch. Prefer passing figure/axes handles into plot instead of caller-workspace variables. Keep mlapp layout thin; math stays in `m/`.
