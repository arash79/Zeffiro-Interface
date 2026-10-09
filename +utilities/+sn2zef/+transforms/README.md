## Folder purpose

Build a 4×4 FreeSurfer CRAS translation from the FreeSurfer reference volume only. Does not run `mri_coreg`, does not read the SimNIBS header, and does not rewrite STL files.

## Main contents

| File | Role |
|------|------|
| `compute_simnibs_to_freesurfer_translation.m` | Translation \(t = -\mathrm{cras}\) from the FreeSurfer volume |

## Code functionality

`MRIread` on the FreeSurfer reference supplies the RAS center. The linear part is identity:

\[
\mathrm{cras} = [c_r;\, c_a;\, c_s],\qquad t = -\mathrm{cras}.
\]

The returned matrix is `eye(4)` with \(t\) in the last column. `simnibs_nii` is unused and kept so existing callers can still pass the SimNIBS volume path.

This is the same scanner-RAS → surface-RAS shift as `utilities.fs2zef.transforms.compute_ras_center_translation`. It does not cancel a relative rotation between the SimNIBS `vox2ras` and the FreeSurfer `vox2ras`.

`export_segmentation_meshes` calls this only in `'alignment_mode','translation'`. Atlas points (`save_volume_atlas_points`) apply the same matrix after voxel→RAS.

## Workflow context

Closed STL vertices from `export_segmentation_meshes` in translation mode stay in SimNIBS `vox2ras`. Zeffiro shifts them by the FreeSurfer CRAS when that 4×4 is stored as `affine_transform` on each `.zef` segmentation row and applied in `zef_process_meshes`. Parent: `../README.md`. Applied at mesh time: `src/mesh/README.md`.

## Usage instructions

```matlab
A = utilities.sn2zef.transforms.compute_simnibs_to_freesurfer_translation( ...
    simnibs_nii, freesurfer_mgz, 'verbose', true);
```

| Argument | Meaning |
|----------|---------|
| `simnibs_nii` | Unused. Retained so callers can still pass `final_tissues.nii.gz`. Not checked with `mustBeFile`. |
| `freesurfer_mgz` | Path to `mri/orig.mgz` (`mustBeFile`). CRAS is read from this volume. |
| `'verbose'` | Print the translation (mm) and the 4×4 (default false) |

Requires `FREESURFER_HOME`. Adds `FREESURFER_HOME/matlab` when that folder is not already on the path.

## Important notes

`utilities.sn2zef.run` writes that 4×4 onto every segmentation row as `affine_transform` when `alignment_mode` is `'translation'` (the default). STL vertices stay in SimNIBS RAS; `zef_process_meshes` applies the matrix. Atlas points are already multiplied by the same matrix in `save_volume_atlas_points`, and import does not transform them again. `'alignment_mode','coregistration'` resamples the volume first, so vertices are already in FreeSurfer space and `affine_matrix` is `[]` (no `affine_transform` field). Legacy `options.force_coreg` is only an alias for that mode when `alignment_mode` is omitted.

## Developer guidance

The matrix is a pure CRAS translation. Do not document it as a two-header `vox2ras` map. Document translation vs coregistration modes whenever changing `export_segmentation_meshes`. Prefer embedding the affine in `.zef` over silent vertex rewrites unless the pipeline explicitly chooses apply-on-disk.
