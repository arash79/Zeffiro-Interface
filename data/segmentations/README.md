# data/segmentations

## Folder purpose

Shipped **surface anatomy** for the multicompartment head demo: FreeSurfer-style `.asc` boundaries, cortex/WM, subcortical structures, 36-parcel labels, sensors, and an `import_segmentation.zef` manifest. Used by **Import → Import data to a new project** and CLI `import_to_new_project` — not loaded automatically at every startup.

## Main contents

Under `multicompartment_head_project/`:

| Kind | Examples |
|------|----------|
| Boundaries | `outer_skin`, `outer_skull`, `inner_skull` |
| Cortex / WM | `lh.pial`, `rh.pial`, `lh.wm`, `rh.wm`, cerebellum cortex/WM |
| Subcortical / CSF / vessels / CC / brainstem | Many `lh.` / `rh.` prefixed ASC files |
| Parcellation | `lh_labels_36`, `rh_labels_36`, `color_table_{lh,rh}_36.mat` |
| Sensors | `electrodes.dat`, `meg_points.dat`, `meg_directions.dat` |
| Manifest | `import_segmentation.zef` |
| Offline regenerators | `fs2zef.sh`, `create_colortable.m`, `create_points.m`, `creat_points.m` (legacy typo name), `read_annotation.m` |

See `multicompartment_head_project/README.md` for file-level detail.

## Code functionality

Data + offline regeneration scripts. Import parsers live under `src/io`. Production FreeSurfer conversion for new subjects: `utilities.fs2zef`.

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
- ASC inventory is large (~60+ surfaces); do not delete label/color_table pairs.
- Regenerators assume FreeSurfer/`SUBJECTS_DIR` and are not required for normal demos.

## Developer guidance

- Prefer regenerating via `fs2zef` rather than hand-editing dozens of ASC files.
- Pitfall: importing without turning compartments **On** before meshing.
