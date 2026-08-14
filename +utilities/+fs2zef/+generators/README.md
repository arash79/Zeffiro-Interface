# `+generators` — write `import_segmentation.zef`

After `makeParcellation.sh` has created ASCII/STL surfaces, this folder writes the CSV manifest Zeffiro’s **Import → Import data to a new project** understands. It does not call FreeSurfer and does not mesh. `utilities.fs2zef.run` is what a user calls; this package is the last stage of that pipeline.

```matlab
% Typical call from run (you rarely invoke this yourself):
utilities.fs2zef.generators.generate_zef_import(output_dir, ...
    "include_electrodes", true, ...
    "include_box", true, ...
    "compute_transforms", true, ...
    "reference_volume", "orig.mgz", ...
    "merge_left_right", true);
```

`generate_zef_import(output_dir, ...)` scans `*.asc` / `*.stl` (skips FreeSurfer **label** `.asc` files), looks up color/sigma/activity from `+config/compartment_mappings` and the LUT, optional CRAS `affine_transform` from `+transforms`, and writes `import_segmentation.zef` (or `options.output_file`).

Name-values used by `run`: `include_electrodes`, `include_box`, `compute_transforms`, `reference_volume`, `segmentation_volume`, `path_prefix`, `merge_left_right`.

`save_dats` / `save_color_tables` write atlas extras (`*.dat` / colortables) when a study needs parcellation points — not invoked by `run`. Parent: [`../README.md`](../README.md). Manifest `type=` rows: [`../../../src/io/README.md`](../../../src/io/README.md).
