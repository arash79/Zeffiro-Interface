# plugins/StripTool

## Folder purpose

Generic **implanted strip / cylinder** geometry as FEM compartments (optional encapsulation) plus contact points. Default head-profile menu: **Forward tools → Strip tool** (`zef_strip_tool_start`).

## Main contents

| File | Role |
|------|------|
| `zef_strip_tool_start` / `_open` / `_window` / `_update` / `_delete` | GUIDE UI lifecycle (`_window` builds the figure; `_open` shows it; `_update` / `_delete` refresh or drop the selected strip) |
| `zef_strip_tool_init` / `_update` / `_add` / `_delete` | `*_strip_cell` lifecycle |
| `zef_create_strip` | Strip geometry |
| `zef_simple_cylinder_generator` | Cylinder mesh for legacy shafts and encapsulation |
| `zef_strip_disc_lattice` / `zef_strip_disc_site` / `zef_strip_disc_patch` | DiSC specification, one active channel, and one physical disk |
| `zef_strip_disc_surface` | DiSC shaft with every physical contact disk |
| `zef_get_strip_parameters` | Parameter pack |
| `zef_strip_coordinate_transform` | Local ↔ world |
| `zef_strip_tool_embed` | `zef_add_compartment` for strip (+ encapsulation) |
| `zef_strip_tool_add_contacts` / `zef_get_strip_contacts` | Sensor contacts |
| `zef_strip_tool_plot` | Preview |

## Code functionality

1. Add strip entry → tip, orientation, model (Omnidirectional 4, Directional 8, Directional 40, DiSC 64 (Shores 2026), DiSC 128 (Abrego G-128)), length, impedance, encapsulation options.
2. **Plot** preview in local/world coordinates.
3. **Embed** creates compartment(s) via `zef_add_compartment`.
4. **Add contacts** writes sensor points for stimulation/recording setups.
5. Geometry edits lock when status is Embedded.

## Workflow context

```
StripTool → compartments + contacts on zef
  → remesh / attach electrodes / forward (EIT/tES/EEG as applicable)
```

## Usage instructions

```matlab
zef_strip_tool_start;
% Add strip → set tip/orientation/length → Plot → Embed → Add contacts
```

## Important notes

- Delete removes that lead from `strip_cell` and removes the sensor contacts added for it (points, get_functions, name-table rows, and the Figure-tool glyphs for that lead). A cached lead field is cleared so the next forward run cannot keep the deleted channels. It does not remove already-embedded compartments.
- Embedded strips should be remeshed before trusting FEM results.
- DiSC 128 is the fabricated Abrego et al. 2023 G-128 wrap: 16×8 aligned sites, 0.080 mm diameter, 0.200 mm axial pitch, 0.250 mm arc pitch, shaft diameter 0.674 mm (Suppl. Fig. 9). Columns are not forced onto 45° spacing. DiSC 64 is the Shores et al. 2026 device: a 32×4 staggered film, 0.230 mm row pitch, 64 wired channels on a 0.800 mm shaft. The 0.080 mm DiSC-64 site diameter is assumed; Shores does not state it. Sources and the lead-field representation are in `DiSC_validation.md`.
- Add contacts writes one sensor per active channel. The complete-electrode faces are the lithographic disks when the queried mesh contains them. A volume lattice coarser than the disk returns a point contact and marks `electrode_representation` as `point_unresolved`. The point-electrode path uses active-channel centers. Default shaft conductivity is the insulating Strip Tool value `1e-15` S/m.
- Registered on `profile/multicompartment_head/zeffiro_plugins.ini` as **Strip tool**. Other profiles still start it with `zef_strip_tool_start`.

## Developer guidance

- Keep coordinate transforms centralized in `zef_strip_coordinate_transform`.
- Pitfall: editing geometry after Embed without clearing status locks.
