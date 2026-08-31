# `utilities.sn2zef` — SimNIBS → Zeffiro STLs

## Folder purpose

Extract **closed compartment surfaces** from SimNIBS `final_tissues.nii.gz` (voxel tetrahedral decomposition via Brainstorm-style atlas helpers), write STLs / atlas points / `import_segmentations.zef`. Public entry: `utilities.sn2zef.run`. Optional Gmsh `.msh` path via `export_from_gmsh_mesh` (vendor `meshLoadGmsh4` — keep original license header).

## Main contents

| Entry | Role |
|-------|------|
| `run.m` | Primary volume → STL / `.zef` pipeline |
| `export_segmentation_meshes.m` | NIfTI + FreeSurfer coreg path |
| `export_from_gmsh_mesh.m` / `meshLoadGmsh4.m` | Gmsh 4 reader path (third-party reader) |
| `readSNLUT.m` | Tissue LUT parser (`final_tissues_LUT.txt`) |
| `save_volume_atlas_points.m` | Atlas point export from labelled volumes |
| `run_and_print_command.m` | Shell/command logging helper |
| `+transforms/` | SimNIBS ↔ FreeSurfer translation helpers |

## Code functionality

**Requires:** `SIMNIBS_HOME/m2m_<id>/final_tissues.nii.gz` + `final_tissues_LUT.txt`; FreeSurfer (`FREESURFER_HOME`, `orig.mgz`) for coreg/export path; a `zef` struct for inflation GPU flags when used.

**`run(zef, subject_id, outFolder, inflation_parameter, options)`:** writes files under `outFolder` (no return value). Taubin inflation iterations via `inflation_parameter` (`0` to skip). Large inflation on full grids is slow.

Does **not** open a full Zeffiro GUI session by itself — output is importable surfaces/manifests for a later `import_to_new_project` / meshing step.

## Workflow context

```
SimNIBS m2m_* tissues
  → utilities.sn2zef.run
  → STL / .zef under outFolder
  → Zeffiro import → mesh → lead field
```

Siblings: `fs2zef` (FreeSurfer), `brainstorm2zef`, `duneuro2zef`.

## Usage instructions

```matlab
utilities.sn2zef.run(zef, 'sub-01', fullfile(pwd,'sn2zef_out'), 0);
% or Gmsh path when you already have a .msh:
utilities.sn2zef.export_from_gmsh_mesh(...);  % see file help
```

## Important notes

- Environment variables and subject folder layout must match SimNIBS conventions.
- `meshLoadGmsh4` is vendor code — do not relicense or strip headers.
- Output coordinate units must match Zeffiro import expectations (typically mm).

## Developer guidance

- Prefer extending `run` options over forking STL writers.
- Keep LUT parsing in `readSNLUT` when SimNIBS label tables change.
- Pitfall: confusing this with `fs2zef` ASC pipelines or expecting `zef.L` after `run`.
