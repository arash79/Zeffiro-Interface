## Folder purpose

Write the CSV manifest `import_segmentation.zef` after FreeSurfer surface export. Does not call FreeSurfer and does not mesh. Last stage of `utilities.fs2zef.run`.

## Main contents

| File | Role |
|------|------|
| `generate_zef_import.m` | Scan surfaces, apply mappings, write `.zef` |

## Code functionality

`generate_zef_import(output_dir, ...)` scans `*.asc` / `*.stl` (skips FreeSurfer **label** `.asc` files), looks up color/sigma/activity from `+config/compartment_mappings` and the LUT, optional CRAS `affine_transform` from `+transforms`, and writes `import_segmentation.zef` (or `options.output_file`).

Name-values used by `run`: `include_electrodes`, `include_box`, `compute_transforms`, `reference_volume`, `segmentation_volume`, `path_prefix`, `merge_left_right`.

## Workflow context

After `makeParcellation.sh` has created ASCII/STL surfaces. Manifest is what **Import → Import data to a new project** consumes. Parent: `../README.md`. Manifest `type=` rows: `src/io/README.md`.

## Usage instructions

```matlab
% Typical call from run (you rarely invoke this yourself):
utilities.fs2zef.generators.generate_zef_import(output_dir, ...
    "include_electrodes", true, ...
    "include_box", true, ...
    "compute_transforms", true, ...
    "reference_volume", "orig.mgz", ...
    "merge_left_right", true);
```

Prefer `utilities.fs2zef.run` for the full pipeline.

## Important notes

This package only writes import assets; meshing happens later in Zeffiro.

## Developer guidance

Keep generator name-values aligned with `run`’s options. When adding row types, update `src/io` docs as well.
