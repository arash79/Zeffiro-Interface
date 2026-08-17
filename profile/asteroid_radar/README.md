# profile / asteroid_radar

## Folder purpose

Zeffiro **startup profile** for asteroid **radar / wireframe** workflows: a two-compartment body (bounding box + asteroid) with density `rho` On, electrical `sigma` Off, and gravity rows in the Mesh-tool forward table.

## Main contents

| File | Role |
|------|------|
| `zeffiro_segmentation.ini` | Two-compartment asteroid template (same layout family as `asteroid_gravity`) |
| `zeffiro_parameters.ini` | `rho` On; `sigma` Off |
| `zeffiro_forward_simulation.ini` | Gravity scalar/vector and gravity-gradient scripts (no separate radar lead-field script) |
| `zeffiro_plugins.ini` | SESAME, **Wireframe creator tool**; gravity-oriented inverse set |
| `zeffiro_init.ini` | Extra `zef` fields after `zef_init` |

| Asset | Path |
|-------|------|
| Saved radar project | `data/example_projects/asteroid_radar_project.mat` |
| Itokawa surfaces | `data/itokawa_model/` |
| Gravity sibling project | `data/example_projects/asteroid_gravity_project.mat` |

## Code functionality

- In this tree the five INIs use the **same gravity physics** as [`asteroid_gravity/`](../asteroid_gravity/README.md).
- Distinction is the **example project and surfaces**, not a different PDE in the forward INI.
- Wireframe creator (`zef_wireframe_creator_start`) supports radar-style wireframes of the body rather than volume reconstruction alone.

## Workflow context

Choose this profile when loading the radar example project or building wireframe views of the asteroid. For volume gravity reconstruction from density, `asteroid_gravity` is the sibling profile with matching forward scripts.

## Usage instructions

1. Segmentation tool **Profile:** → `asteroid_radar`, then Apply plugin/parameter INIs and Mesh tool **Update from profile**, **or** set **Profile name** in System settings and restart.
2. **Project → Open project** on `asteroid_radar_project.mat`, or import Itokawa surfaces and run a gravity **Run script** row.
3. **Multi-tools → Wireframe creator tool** when you need a radar-style wireframe.

Parent: [`../README.md`](../README.md).

## Important notes

- The gravity profile’s SESAME INI row has extra spaces around commas; this folder’s row does not. Both still call `SESAME_App_run`.
- Profile dropdown alone does not reload INIs.

## Developer guidance

Treat INI edits in lockstep with `asteroid_gravity` unless intentionally diverging forward or plugin rows. Document example-project paths here when assets move. Parent overview: [`../README.md`](../README.md).
