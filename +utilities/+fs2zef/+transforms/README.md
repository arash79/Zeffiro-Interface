# `+transforms` — CRAS translation only

Specialized FreeSurfer volumes (thalamic nuclei, hippocampal subfields) often do not share the `orig.mgz` centre. Surfaces from `mri_mc` are still in tkr RAS millimetres; Zeffiro then applies a 4×4 `affine_transform` from the `.zef` row at `zef_process_meshes`.

```matlab
A = utilities.fs2zef.transforms.compute_affine_transform( ...
    fullfile(mri_dir, "ThalamicNuclei.v13.T1.FSvoxelSpace.mgz"), ...
    fullfile(mri_dir, "orig.mgz"));
% A is translation-only: dx = c_r(source) - c_r(target), same for S/A.
```

`compute_affine_transform(source_mgz, target_mgz)` returns that matrix from `mri_info` volume centres (`c_r`, `c_s`, `c_a` via `get_volume_centers`). There is no rotation.

`apply_affine_transform(mesh_file, affine_matrix)` rewrites vertices in that file. `run` does not call apply; it embeds the matrix in the `.zef` so Zeffiro applies it at mesh time. Parent: [`../README.md`](../README.md).
