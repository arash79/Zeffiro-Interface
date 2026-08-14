# `+transforms` — SimNIBS RAS → FreeSurfer RAS (header affine)

SimNIBS `final_tissues.nii.gz` and FreeSurfer `mri/orig.mgz` are often the same anatomy in **different RAS frames** (NIfTI orientation vs FreeSurfer). Closed STL vertices from `export_segmentation_meshes` in **translation** mode are written in SimNIBS `vox2ras`. Zeffiro can still place them on the FreeSurfer anatomy if a 4×4 `affine_transform` is stored on each `.zef` segmentation row and applied later in `zef_process_meshes` (post-multiply mesh rows).

This folder builds that matrix from **volume headers only** (`MRIread` `vox2ras` + CRAS). It does not run `mri_coreg` and does not rewrite STL files.

## When you need it

- You called `export_segmentation_meshes(..., 'alignment_mode','translation')` (the worker default) and you want Zeffiro to apply the SimNIBS→FS map at mesh time.
- `utilities.sn2zef.run` currently **discards** the returned affine (`[~, vertex_info] = …`) and writes `import_segmentations.zef` **without** `affine_transform`. If you import that folder as-is, surfaces stay in the STL vertex frame (SimNIBS RAS). To get FreeSurfer RAS via this matrix, call the worker yourself and put the 4×4 into the `.zef`, or use `'alignment_mode','coregistration'` so vertices are already in FS space (`affine_matrix` is then `[]`).

## Function

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

### What the 4×4 is

From the two `vox2ras` linear parts \(R_\mathrm{sim}\), \(R_\mathrm{fs}\) and CRAS centres:

\[
R = R_\mathrm{fs}\, R_\mathrm{sim}^{-1},\qquad
t = c_\mathrm{fs} - R\, c_\mathrm{sim}.
\]

If \(R_\mathrm{sim}\) is ill-conditioned (`cond > 1e8`) or the divide throws, the function falls back to a **pure translation** \(t = c_\mathrm{fs} - c_\mathrm{sim}\) (legacy centre shift). That fallback does not correct a relative rotation.

`export_segmentation_meshes` calls this only in translation mode. Atlas points (`save_volume_atlas_points`) can apply the same matrix after voxel→RAS. Parent pipeline: [`../README.md`](../README.md). Applied at mesh time: [`../../../src/mesh/README.md`](../../../src/mesh/README.md) (`zef_process_meshes`).
