## Folder purpose

Sample **multicompartment head** anatomy used by Zeffiro demos and by `zeffiro_interface(..., 'import_to_new_project', ...)`. Surfaces are FreeSurfer-style `.asc` meshes; `import_segmentation.zef` lists compartment files, conductivities, and import options for `zef_import_segmentation`.

## Main contents

- `import_segmentation.zef` — import recipe consumed by `zef_import_segmentation`
- `*.asc` — compartment and hemisphere surfaces listed in that recipe (inner/outer skull, cortex, subcortical labels)
- `electrodes.dat` — sample electrode coordinates for this anatomy
- `color_table_*.mat` — 36-parcel parcellation colortables
- `lh_labels_36.asc` / `rh_labels_36.asc` — parcel point tables paired with the colortables

## Code functionality

This folder is **data**, not a runtime library. The importer reads only paths named in `import_segmentation.zef`. To rebuild a similar sample from a FreeSurfer subject, use `utilities.fs2zef`.

## Workflow context

Import → mesh → lead field demos. Parent documentation: `data/README.md` and `+utilities/+fs2zef/README.md`.

## Usage instructions

```matlab
zef = zeffiro_interface('start_mode', 'nodisplay', ...
    'import_to_new_project', fullfile(pwd, ...
    'data', 'segmentations', 'multicompartment_head_project', ...
    'import_segmentation.zef'));
```

## Important notes

- `.asc` coordinates match the project's millimetre RAS-like frame used by `zef_import_asc`.
- Grey-matter rows in the manifest point at `lh.pial` / `rh.pial` plus the 36-parcel tables.

## Developer guidance

Prefer regenerating via `utilities.fs2zef` rather than hand-editing many `.asc` files. Keep this folder's filenames in sync with `import_segmentation.zef`.
