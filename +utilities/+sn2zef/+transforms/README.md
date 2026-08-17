## Folder purpose

Build the SimNIBS RAS → FreeSurfer RAS header affine (4×4) from volume headers only. Does not run `mri_coreg` and does not rewrite STL files.

## Main contents

| File | Role |
|------|------|
| `compute_simnibs_to_freesurfer_translation.m` | Header-based SimNIBS→FS transform |

## Code functionality

From the two `vox2ras` linear parts \(R_\mathrm{sim}\), \(R_\mathrm{fs}\) and CRAS centres:

\[
R = R_\mathrm{fs}\, R_\mathrm{sim}^{-1},\qquad
t = c_\mathrm{fs} - R\, c_\mathrm{sim}.
\]

If \(R_\mathrm{sim}\) is ill-conditioned (`cond > 1e8`) or the divide throws, falls back to pure translation \(t = c_\mathrm{fs} - c_\mathrm{sim}\) (legacy centre shift). That fallback does not correct relative rotation.

`export_segmentation_meshes` calls this only in `'alignment_mode','translation'`. Atlas points (`save_volume_atlas_points`) can apply the same matrix after voxel→RAS.

## Workflow context

SimNIBS `final_tissues.nii.gz` and FreeSurfer `mri/orig.mgz` are often the same anatomy in different RAS frames. Closed STL vertices from `export_segmentation_meshes` in translation mode are in SimNIBS `vox2ras`. Zeffiro can place them on FreeSurfer anatomy if a 4×4 `affine_transform` is stored on each `.zef` segmentation row and applied in `zef_process_meshes`. Parent: `../README.md`. Applied at mesh time: `src/mesh/README.md`.

## Usage instructions

```matlab
A = utilities.sn2zef.transforms.compute_simnibs_to_freesurfer_translation( ...
    simnibs_nii, freesurfer_mgz, 'verbose', true);
```

| Argument | Meaning |
|----------|---------|
| `simnibs_nii` | Path to `final_tissues.nii.gz` (`mustBeFile`) |
| `freesurfer_mgz` | Path to `mri/orig.mgz` |
| `'verbose'` | Print CRAS and the 4×4 (default false) |

Requires `FREESURFER_HOME` so `MRIread` is on the path (same `matlab/` / `fsfast/toolbox` addpath as the STL worker).

## Important notes

`utilities.sn2zef.run` currently **discards** the returned affine (`[~, vertex_info] = …`) and writes `import_segmentations.zef` **without** `affine_transform`. Importing that folder as-is leaves surfaces in the STL vertex frame (SimNIBS RAS). To get FreeSurfer RAS via this matrix, call the worker yourself and put the 4×4 into the `.zef`, or use `'alignment_mode','coregistration'` so vertices are already in FS space (`affine_matrix` is then `[]`).

## Developer guidance

Document translation vs coregistration modes whenever changing `export_segmentation_meshes`. Prefer embedding affine in `.zef` over silent vertex rewrites unless the pipeline explicitly chooses apply-on-disk.
