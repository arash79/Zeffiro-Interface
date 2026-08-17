# data/media

## Folder purpose

**Static screenshots and demo media** for papers, slides, posters, and the LaTeX technical manual. Assets here illustrate meshes, reconstructions, EIT models, CEM electrodes, and parcellation UI. They are **not** loaded by `zeffiro_interface` at runtime and are not part of the solver data path (`segmentations`, `example_projects`, electrode libraries).

Treat the folder as a curated media library for documentation and communication, distinct from `data/log/` (ephemeral UI capture dumps during development) and `assets/fig/` (logos and icons the GUI / waitbar may `imread` by name).

## Main contents

| File | Typical subject |
|------|-----------------|
| `aivokuva.png` | Brain / cortex visualization still |
| `cem_electrodes.png` | Complete electrode model / electrode depiction |
| `eit_model.png` | EIT model illustration |
| `eit_reconstruction.png` | EIT reconstruction still |
| `high_res_meshes.png` | High-resolution mesh rendering |
| `surface_meshes.png` | Surface mesh overview |
| `volume_mesh.png` | Volume mesh still |
| `volume_mesh_with_edges.png` | Volume mesh with edge overlay |
| `rec_1_surf.png` / `rec_1_surf_2.png` / `rec_1_surf_3.png` | Surface reconstruction views |
| `rec_1_vol_cut.png` | Volume cut reconstruction view |
| `parcellation_brain.png` | Parcellation on brain surface |
| `parcellation_correlation.png` | Parcellation correlation graphic |
| `parcellation_tool.png` | Parcellation tool UI capture |
| `time_lapse.avi` | Time-series / reconstruction movie demo |
| `README.md` | This documentation |

Exact scientific captions belong in the paper or manual that includes them; filenames are descriptive hints only.

## Code functionality

None — binary assets only. No MATLAB loaders, no `addpath` contract, no INI references required for solving forward/inverse problems.

Documentation builds may `\includegraphics` paths under `data/media/` or copy files into a paper’s `figures/` tree. Prefer relative paths from the consuming TeX / Markdown project rather than hard-coding machine-specific absolute paths.

## Workflow context

```
Authoring (paper / slides / documentation/main.tex)
        │
        └─► copy or \includegraphics from data/media/*

Runtime zeffiro_interface
        │
        └─► does not read this folder
```

| Nearby folder | Role |
|---------------|------|
| `data/log/` | Dev UI screenshots / logs (ephemeral) |
| `assets/fig/` | Product logos / symbols for GUI |
| `data/example_projects/` | Loadable `.mat` projects |
| `documentation/` | Manual that may reference these stills |

## Usage instructions

- For LaTeX: copy needed PNGs next to the manuscript or include with a path your build allows.
- For slides: export or link the PNG/AVI directly; `time_lapse.avi` is large — compress or trim for web.
- For MATLAB demos: do **not** `addpath` this folder for logic; if a script must show a still, `imread` an explicit fullfile path.
- When replacing an image used in a published figure, keep the old filename if the manual already references it, or update all includes.

## Important notes

- Large binaries (especially `time_lapse.avi` and high-res mesh PNGs); avoid duplicating into `assets/` unless the GUI must load them by name.
- Not required to run forward/inverse problems or open example projects.
- Do not commit additional multi‑GB captures here without team agreement.
- Distinct from `data/log/inspect_*.png` / `ui_*.png` development captures — those are tooling byproducts, not documentation media.

## Developer guidance

- Prefer `assets/fig` for logos the waitbar, menus, and splash code load by filename.
- Keep scientific screenshots captioned in the paper/manual; do not rely on this README alone for ethics / consent / dataset provenance.
- If a figure becomes part of the official PDF manual, also note the include path in `documentation/README.md` or the relevant `.tex` file.
- When deleting or renaming media, grep `documentation/` and repo Markdown for the old basename.
- Do not mix runtime sensor/mesh payloads into this folder — use `data/segmentations` or `data/example_projects` for those.
