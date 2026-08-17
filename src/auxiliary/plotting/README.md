# src/auxiliary/plotting

## Folder purpose

Holds a single unfinished helper extracted from an older plot-tool path. It is **not** part of the live visualization pipeline (`src/gui/plot`). Keep it only as a reference for reconstruction-field reshaping logic; do not wire menus or figure-tool callbacks here.

## Main contents

| File | Role |
|------|------|
| `zef_get_reconstruction_field.m` | Reshape a 3-component reconstruction and branch on display `type` (amplitude / mean / normal-projected), with optional scale, smooth, and parcellation steps |

There are no other MATLAB sources in this folder.

## Code functionality

Declared signature:

```matlab
reconstruction = zef_get_reconstruction_field(reconstruction, s_i_ind, intersect_ind)
```

Observed behavior from the source:

1. Reshapes `reconstruction` into a 3×N layout for XYZ components.
2. Branches on undeclared workspace variable `type` (and related `I_*_rec`, `n_vec_aux`, `zef.*` fields).
3. `intersect_ind` appears in the signature but is not used.
4. The file contains leftover bare `end` tokens after the function body — treat as unfinished.

**Inputs (intended):** reconstruction vector/matrix, source index map `s_i_ind`, optional intersection mask.  
**Outputs (intended):** filtered/reshaped reconstruction for plotting.  
**Dependencies:** assumes a carefully prepared caller workspace; not self-contained.

## Workflow context

| Related path | Relationship |
|--------------|--------------|
| `src/gui/plot/zef_plot_*.m` | Production mesh / reconstruction plotting |
| `src/gui/tools/zef_figure_tool.m` | Live figure UI |
| `tools/plugins/PlotMeshesProto` | Experimental plotter (also not menu-wired) |

No `.m` callers were found in the repository; only documentation references this file.

## Usage instructions

Do not call from new code. For production plotting:

```matlab
% Prefer the GUI plot path, e.g. from figure / mesh visualization tools
% or programmatic helpers under src/gui/plot/
```

If you must experiment with this extract, first open it in the Editor and resolve undeclared variables before any `run`.

## Important notes

- Will error unless `type`, index masks, and `zef` fields exist in the caller workspace.
- Not added as a dedicated path entry — only reachable via `genpath(src)`.
- Header comments describe it as a leftover extract; trust that over any older README prose.

## Developer guidance

- Port any useful reshape/branch logic into a tested function under `src/gui/plot` with explicit inputs (no ambient workspace).
- Delete or quarantine this file once the logic is absorbed — do not leave two plot pipelines.
- Common pitfall: assuming this is the “official” reconstruction field API; it is not.
