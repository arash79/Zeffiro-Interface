# `asteroid_gravity`

Gravity lead-field profile for a two-compartment asteroid (bounding box + body). Density `rho` is the active tissue parameter; electrical `sigma` and electrode CEM rows are Off.

Switch: segmentation tool **Profile:** then Apply plugin/parameter INIs and Mesh tool **Update from profile**, or set **Profile name** in **Settings → System settings (zeffiro_interface.ini)** and restart. Details: [`profile/README.md`](../README.md). Sample meshes: `data/itokawa_model/`. Saved project: `data/example_projects/asteroid_gravity_project.mat`.

## INIs

| File | This profile |
|------|----------------|
| `zeffiro_segmentation.ini` | Tags `c1` (Box, `_sources == -1` PML/bounding box, ρ=0), `c2` (Asteroid, unconstrained field, ρ=2000). |
| `zeffiro_parameters.ini` | `rho` On; `sigma` and electrode impedance/radii Off. |
| `zeffiro_forward_simulation.ini` | Gravity scalar/vector and gravity-gradient scalar/vector (`zef_gravity_*`). No EEG/MEG. |
| `zeffiro_plugins.ini` | SESAME, wireframe creator. Drops Kalman, NSE, SL1, DTI, EXP Lasso. Adds EXP IAS RAMUS. GMM App (JL) only. |
