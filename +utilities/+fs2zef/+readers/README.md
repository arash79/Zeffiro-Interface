# +utilities/+fs2zef/+readers

## Folder purpose

Low-level **FreeSurfer file parsers** used by the `fs2zef` import pipeline when building Zeffiro segmentation packages. Not the GUI importers (`zef_import_asc` / `zef_import_segmentation`).

## Main contents

| Function | Input | Output |
|----------|-------|--------|
| `read_ascii_segmentation_file` | FreeSurfer ASCII surface | `nodes`, `faces` |
| `readFSLUT` | `$FREESURFER_HOME/FreeSurferColorLUT.txt` | struct `No/Name/R/G/B/A` |
| `get_volume_centers` | `.mgz` via `mri_info` | `c_r`, `c_s`, `c_a` |

## Code functionality

- ASCII surface: validates `#!ascii version of…` header, reads node/face counts, parses geometry (`mustBeFile`).
- `readFSLUT`: `textscan` of LUT, skips `#` comments; errors if `FREESURFER_HOME` unset or file missing.
- `get_volume_centers`: `bash -lc` with `SetUpFreeSurfer.sh` then `mri_info`; regex for `c_r`/`c_s`/`c_a`.

## Workflow context

Called as `utilities.fs2zef.readers.*` from `+generators/generate_zef_import` (LUT) and `+transforms/compute_affine_transform` (centers), and from the in-package pipeline test. Upstream of writing `import_segmentation.zef`.

## Usage instructions

```matlab
setenv('FREESURFER_HOME','/path/to/freesurfer');
lut = utilities.fs2zef.readers.readFSLUT();
[nodes,faces] = utilities.fs2zef.readers.read_ascii_segmentation_file("lh.pial.asc");
[c_r,c_s,c_a] = utilities.fs2zef.readers.get_volume_centers(mgzPath);
```

Prefer the package generators over calling these alone unless debugging I/O.

## Important notes

- `readFSLUT` and `get_volume_centers` require a working FreeSurfer install and environment.
- `get_volume_centers` shells out; sandbox/CI without FS will fail.

## Developer guidance

Keep validation errors explicit (`ERR: fname: …`). New FreeSurfer text formats should follow the same `arguments` + `onCleanup` fopen pattern. Callers should use the package namespace, not bare function names, for clarity on the path.
