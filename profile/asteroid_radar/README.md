# `asteroid_radar`

This folder is the asteroid **radar / wireframe** profile: a two-compartment body (bounding box + asteroid) with density `rho` On, electrical `sigma` Off, and gravity rows in the Mesh-tool forward table.

In **this** tree the five INIs are the same physics as [`asteroid_gravity/`](../asteroid_gravity/README.md): gravity (scalar/vector) and gravity-gradient scripts, SESAME, and **Wireframe creator tool**. There is no separate radar lead-field script in `zeffiro_forward_simulation.ini`. The distinction is the **example project and surfaces**, not a different PDE in the INI.

| Asset | Path |
|-------|------|
| Saved radar project | `data/example_projects/asteroid_radar_project.mat` |
| Itokawa surfaces (exterior, mantle, void) | `data/itokawa_model/` |
| Gravity sibling project | `data/example_projects/asteroid_gravity_project.mat` |

Open the radar project with **Project → Open project**, or import the Itokawa surfaces and run a gravity **Run script** row. Use **Multi-tools → Wireframe creator tool** (`zef_wireframe_creator_start`) when you need a radar-style wireframe of the body rather than a volume reconstruction.

## Switching here

Segmentation tool **Profile:** → `asteroid_radar`, then Apply plugin / parameter INIs and Mesh tool **Update from profile**, **or** set **Profile name** in **Settings → System settings (zeffiro_interface.ini)** and restart. Parent: [`profile/README.md`](../README.md).

The gravity profile’s SESAME INI row has extra spaces around commas (`SESAME, inverse_tools, SESAME_App_run`); this folder’s row does not. Both still call `SESAME_App_run`.
