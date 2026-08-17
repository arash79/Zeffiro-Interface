## Folder purpose

Tissue compartments (scalp, skull, CSF, brain, …): each is a closed surface plus flags (on/off, conductivity, sources, merge/invert, color). This folder creates tagged fields on `zef`, fills the Segmentation-tool table, and answers “is this point inside this tissue?” during volume-mesh labeling.

## Main contents

| File | Kind | Role |
|------|------|------|
| `zef_create_compartment.m` | function | Default `<tag>_*` fields |
| `zef_compartment_tag.m` | function | Unused tag string |
| `zef_build_compartment_table.m` | function | Fill `h_compartment_table` |
| `zef_turn_compartment_onoff.m` | function | Batch `_on` |
| `zef_compartment_to_subcompartment.m` | function | Index map to submesh ranges |
| `zef_tetra_in_compartment.m` | function | Inside test for labeling |
| `zef_point_in_compartment.m` | function | Inside test + distance |
| `zef_color_label.m` | function | Figure-tool name labels |

## Code functionality

Each tag (e.g. `sc1`) owns dynamic fields: `_on`, `_sigma`, `_color`, `_points`, `_triangles`, `_priority`, `_visible`, `_merge`, `_invert`, `_sources`, …. `zef_update` uses `eval` on those names — tags must be valid MATLAB field names.

Table columns (from `zef_init_fields_compartment_table`): **Index**, **On**, **Name**, **Visible**, **Surface nodes**, **Surface triangles**, **Merge**, **Invert normal**, **Activity**, plus parameter-profile Segmentation columns. **Index** is labeling priority (lower first). Rows are reverse of `zef.compartment_tags`.

Inside tests: `zef_tetra_in_compartment` in the meshing loop; `zef_point_in_compartment` adds a distance vector. Cost scales with mesh resolution × tissue count. `zef_compartment_to_subcompartment` maps compartment index to active submesh face ranges for source placement.

## Workflow context

Edited in **ZEFFIRO Interface: Segmentation tool**. Cell edit → `zef_update`. Add → `zef_add_compartment` → `zef_create_compartment` + tag. Delete → `zef_delete_compartment`. Toggle on/visible; Import surface mesh (STL/points/triangles); Lock on blocks toggles. Importing a `.zef` bundle calls `zef_create_compartment` per tissue then `zef_build_compartment_table`. Empty tables can be seeded from `profile/<profile>/zeffiro_segmentation.ini`.

## Usage instructions

```matlab
zef = zef_create_compartment(zef, 'cortex');
zef = zef_build_compartment_table(zef);
zef = zef_update(zef);
```

Do not hard-code tissue names in forward code; iterate `zef.compartment_tags`.

## Important notes

- GUI add/delete live in `src/gui/callbacks`, not here.
- Profile `multicompartment_head_legacy` ships a 25-compartment template; `multicompartment_head` is typically empty until import.

## Developer guidance

New compartment properties: column in the segmentation INI + `zef_get_data_compartment_table` + `zef_create_compartment` defaults + `zef_init_fields_compartment_table` if standard. Inside-test changes affect all mesh labeling; use `+examples/+meshing`.
