# Tissue compartments (`src/compartments`)

A Zeffiro head model is a list of **compartments** (scalp, skull, CSF, brain, …). Each one is a closed surface plus flags: on/off, conductivity, whether it may contain sources, merge/invert, color.

This folder creates those tagged fields on `zef`, fills the Segmentation-tool table, and answers “is this point inside this tissue?” while the volume mesh is labeled.

## What you do in the GUI

Open **ZEFFIRO Interface: Segmentation tool** (always created at startup). The **Compartments:** table is the editor.

Verified labels from `zef_segmentation_tool_app_exported` (menus live on that window, wired in `zef_menu_tool.m`):

| Control | Effect |
|---------|--------|
| Table cell edit | `zef_update` (writes `<tag>_*` fields) |
| **Add compartment** | `zef_add_compartment` → `zef_create_compartment` + new tag from `zef_compartment_tag` |
| **Delete compartment(s)** | `zef_delete_compartment`; then `zef_init_sensors_parameter_profile` |
| **Toggle on** | flip column **On** for the selection (no-op if **Lock on**) |
| **Toggle visible** | flip column **Visible** |
| **Import surface mesh → Full mesh (STL file)** | `zef.surface_mesh_type='stl'` → `zef_get_surface_mesh` |
| **Import surface mesh → Points (DAT file)** / **Triangles (DAT file)** | same helper, type `'points'` / `'triangles'` |
| **Lock on** | `zef.lock_on` — blocks on/off toggles |

Table columns (from `zef_init_fields_compartment_table`): **Index**, **On**, **Name**, **Visible**, **Surface nodes**, **Surface triangles**, **Merge**, **Invert normal**, **Activity**, then extra columns from the parameter profile whose context is `Segmentation`.

**Index** is labeling **priority** (lower number is processed first in mesh labeling). Rows in the table are the reverse of `zef.compartment_tags`. `zef_update` sorts by priority after each edit.

Importing a `.zef` bundle (**Import → Import data to a new project**) calls `zef_create_compartment` for every tissue in the manifest, then `zef_build_compartment_table`.

## Fields on `zef`

Each tag (e.g. `sc1`) owns dynamic fields: `sc1_on`, `sc1_sigma`, `sc1_color`, `sc1_points`, `sc1_triangles`, `sc1_priority`, `sc1_visible`, `sc1_merge`, `sc1_invert`, `sc1_sources`, … `zef_update` uses `eval` on those names, so a tag must be a valid MATLAB field name.

`zef_build_compartment_table` can seed an empty table from `profile/<profile>/zeffiro_segmentation.ini`. Profile `multicompartment_head_legacy` ships a 25-compartment template; `multicompartment_head` is typically empty until import.

## Inside tests (mesh labeling)

`zef_create_fem_mesh` labels tetrahedra by testing centroids against each closed surface:

- `zef_tetra_in_compartment` — used in the meshing inner loop (nodes vs `reuna_p` / `reuna_t`)
- `zef_point_in_compartment` — same idea plus a distance vector; takes `zef` for options

These run once per tetrahedron per compartment; cost scales with mesh resolution and tissue count.

`zef_compartment_to_subcompartment` maps a compartment index to the active **submesh** index range (surface pieces that belong to one tissue for source placement).

`zef_turn_compartment_onoff` sets every `<tag>_on` from a vector (scripted batch toggle).

`zef_color_label` toggles the name label of a compartment in the Figure tool (not the table color).

## Scripting

```matlab
zef = zef_create_compartment(zef, 'cortex');
zef = zef_build_compartment_table(zef);
zef = zef_update(zef);
```

Do not hard-code tissue names in forward code; iterate `zef.compartment_tags`.

## Files

| File | Kind | Role |
|------|------|------|
| `zef_create_compartment.m` | function | Default `<tag>_*` fields |
| `zef_compartment_tag.m` | function | Unused tag string |
| `zef_build_compartment_table.m` | function | Fill `h_compartment_table` |
| `zef_turn_compartment_onoff.m` | function | Batch `_on` |
| `zef_compartment_to_subcompartment.m` | function | Index map |
| `zef_tetra_in_compartment.m` | function | Inside test for labeling |
| `zef_point_in_compartment.m` | function | Inside test + distance |
| `zef_color_label.m` | function | Figure-tool name labels |

## Developer notes

- New compartment properties: column in the segmentation INI + `zef_get_data_compartment_table` + `zef_create_compartment` defaults + `zef_init_fields_compartment_table` if it is a standard column.
- Inside-test changes affect all mesh labeling; use `+examples/+meshing`.
- GUI add/delete live in `src/gui/callbacks`, not here.
