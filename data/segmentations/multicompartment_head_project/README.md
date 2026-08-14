# data/segmentations/multicompartment_head_project

Sample **multicompartment head** anatomy used by Zeffiro demos and by `zeffiro_interface(..., 'import_to_new_project', ...)`. Surfaces are FreeSurfer-style `.asc` meshes; `import_segmentation.zef` lists compartment files, conductivities, and import options for `zef_import_segmentation`.

This folder is **data plus a few one-off conversion scripts**, not a runtime library. Parent documentation is `data/README.md` and `+utilities/+fs2zef/README.md`.

## What lives here

- `import_segmentation.zef` — import recipe consumed by `zef_import_segmentation`.
- `*.asc` — compartment and hemisphere surfaces (inner/outer skull, cortex, subcortical labels).
- `electrodes.dat` — sample electrode coordinates for this anatomy.
- `color_table_*.mat` — parcellation colortables produced by `create_colortable.m`.
- `fs2zef.sh` — shell helper used when regenerating this sample from FreeSurfer.

## MATLAB helpers (not on the startup path)

| File | Role |
|------|------|
| `create_colortable.m` | Script: read `dir_name/label/*.annot` via FreeSurfer `read_annotation`, write `color_table_{lh,rh}_{76,36}.mat`. |
| `create_points.m` | Script: ASCII label tables → `*_point_*.dat` (see script notes: `lh_point_36.dat` is overwritten). |
| `creat_points.m` | Historical misspelling; one-file variant writing `lh_point.dat`. |
| `read_annotation.m` | **Third-party** FreeSurfer `Read_Brain_Annotation` (Bruce Fischl / MGH). Do not treat as Zeffiro-owned. |

## How it is used

```matlab
zef = zeffiro_interface('start_mode', 'nodisplay', ...
    'import_to_new_project', fullfile(pwd, ...
    'data', 'segmentations', 'multicompartment_head_project', ...
    'import_segmentation.zef'));
```

The importer does not run `create_points.m` or `create_colortable.m`; those are offline regenerators if you rebuild the sample from a FreeSurfer subject.

## Assumptions

- `.asc` coordinates match the project's millimetre RAS-like frame used by `zef_import_asc`.
- `read_annotation.m` is MGH-licensed FreeSurfer code; keep its copyright block intact.
