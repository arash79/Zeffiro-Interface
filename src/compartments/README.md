# src/compartments

## Folder purpose

**Tissue compartment model** inside `zef`: create tagged substructs, sync the segmentation-tool compartment table, and provide geometric inside-tests used during FEM mesh labeling and visualization.

## Main contents

| File | Role |
|------|------|
| `zef_create_compartment.m` | Allocate `zef.<tag>_on`, `_sigma`, `_color`, `_points`, `_triangles`, … |
| `zef_compartment_tag.m` | Generate unique tag string for new compartment |
| `zef_build_compartment_table.m` | Fill `h_compartment_table` from `compartment_tags` + profile |
| `zef_turn_compartment_onoff.m` | Batch toggle `<tag>_on` |
| `zef_compartment_to_subcompartment.m` | Map compartment index → active submesh indices |
| `zef_tetra_in_compartment.m` | Tetra centroid inside closed surface (mesh labeling) |
| `zef_point_in_compartment.m` | Point-in-compartment test + distance vector |
| `zef_color_label.m` | Sync compartment label graphics |

## Code functionality

Each compartment is a **dynamic field prefix** on `zef` (e.g. `sc1_on`, `sc1_sigma`, `sc1_points`). `zef_build_compartment_table` reads `profile/<profile>/zeffiro_segmentation.ini` on first build — `multicompartment_head_legacy` ships a 25-compartment template; `multicompartment_head` leaves an empty template for import-driven setups.

`zef_tetra_in_compartment` is called thousands of times during `zef_create_fem_mesh` labeling — performance scales with mesh resolution and compartment count.

## Workflow context

| Consumer | Usage |
|----------|--------|
| `src/io/zef_import_segmentation` | Creates compartments from `.zef` manifest |
| `src/gui/callbacks/zef_add_compartment.m` | User add via GUI |
| `src/mesh` | Labeling and refinement |
| `src/forward` | Conductivity `zef.sigma` per compartment |
| `zeffiro_interface` | `zef_build_compartment_table` after import |

## Usage instructions

```matlab
zef = zef_create_compartment(zef, 'cortex');
zef = zef_build_compartment_table(zef);
zef = zef_update(zef);
```

GUI: Segmentation tool compartment table — add/delete via Edit menu callbacks.

## Important notes

- `zef_update` uses `eval` on `<tag>_*` fields — tags must be valid MATLAB struct field names.
- Import paths in `data/segmentations/*/import_segmentation.zef` reference `.asc` surfaces relative to `data/`.
- Subcompartment indices link surface meshes to volume domains for source placement.

## Developer guidance

- New compartment properties: add columns to segmentation INI + `zef_get_data_compartment_table` + `zef_create_compartment` defaults.
- Inside-test changes affect all mesh labeling — regression-test with `+examples/+meshing`.
- Do not hard-code compartment names in forward code; iterate `zef.compartment_tags`.
