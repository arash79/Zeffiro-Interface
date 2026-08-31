# data/segmentations

## Folder purpose

Shipped **surface anatomy** for the multicompartment head demo: FreeSurfer-style `.asc` boundaries, cortex/WM, subcortical structures, 36-parcel labels, sensors, and an `import_segmentation.zef` manifest. Used by **Import → Import data to a new project** and CLI `import_to_new_project` — not loaded automatically at every startup.

## Main contents

Under `multicompartment_head_project/`:

| Kind | Examples |
|------|----------|
| Boundaries | `outer_skin`, `outer_skull`, `inner_skull` |
| Cortex / WM | `lh.pial`, `rh.pial`, `lh.wm`, `rh.wm`, cerebellum cortex/WM |
| Subcortical / CSF / CC / brainstem | `lh.` / `rh.` paired ASC files plus unprefixed CC / ventral DC / brainstem |
| Parcellation | `lh_labels_36`, `rh_labels_36`, `color_table_{lh,rh}_36.mat` |
| Sensors | `electrodes.dat` |
| Manifest | `import_segmentation.zef` |

See `multicompartment_head_project/README.md` for file-level detail.

## Code functionality

Data only. Import parsers live under `src/io`. Production FreeSurfer conversion for new subjects: `utilities.fs2zef`.

## Workflow context

```
import_segmentation.zef
  → compartments on zef
  → Mesh tool Create FEM mesh
  → lead_field → inverse
```

Related: `data/example_projects/*.mat` (prebuilt sessions), `+examples/+importing`.

## Usage instructions

```matlab
zef = zeffiro_interface('start_mode','nodisplay', ...
    'import_to_new_project', fullfile(pwd,'data','segmentations', ...
    'multicompartment_head_project','import_segmentation.zef'));
```

Or GUI Import to a new project and browse to this folder’s manifest.

## Important notes

- Coordinates are typically **mm**.
- The shipped inventory matches `import_segmentation.zef`; do not delete label/color_table pairs used by that manifest.

## Developer guidance

- Prefer regenerating via `utilities.fs2zef` rather than hand-editing dozens of ASC files.
- Pitfall: importing without turning compartments **On** before meshing.
