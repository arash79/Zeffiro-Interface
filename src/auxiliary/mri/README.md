# MRI affine helpers (`src/auxiliary/mri`)

One-off alignment of point clouds with a 4×4 homogeneous matrix. **Not** on any Zeffiro menu. The Segmentation-tool transform table (`zef_apply_transform`, Mesh tool **Apply transform**) is what a GUI user uses to move compartments and sensors.

Use this folder when a study script already has an MRI-derived affine and needs to apply it to an N×3 point list without going through `zef`.

| File | Kind | Role |
|------|------|------|
| `myAffine3d.m` | function | `point = myAffine3d(point, matrix)` — `point` is N×3; `matrix` is 4×4. Homogeneous multiply, return xyz. |
| `scriptForAlignment.m` | **script** | Hard-coded 4×4 `T` then transform; edit the matrix in the file. Not a reusable API. |

FreeSurfer CRAS translations used by `fs2zef` live in `+utilities/+fs2zef/+transforms`, not here. Parent auxiliary overview: [../README.md](../README.md).
