# `+readers` — FreeSurfer files → MATLAB

Low-level parsers used while writing `import_segmentation.zef`. They are not the Zeffiro GUI importers (`zef_import_asc` / `zef_import_segmentation`).

| Function | Input | Output |
|----------|-------|--------|
| `readFSLUT` | `$FREESURFER_HOME/FreeSurferColorLUT.txt` | Table of label / name / RGB |
| `readAsegStatsFile` | `mri_segstats` text | Compartment stats table |
| `read_ascii_segmentation_file` | FreeSurfer `.asc` surface | `nodes`, `faces` |
| `read_ascii_label_file` | Label `.asc` | `labels`, `colors` (not a mesh) |
| `get_volume_centers` | `.mgz` via `mri_info` | `c_r`, `c_s`, `c_a` for CRAS translation |

`generate_zef_import` uses LUT + ASCII readers to skip label files and assign colors. `get_volume_centers` feeds `+transforms`. Parent: [`../README.md`](../README.md).
