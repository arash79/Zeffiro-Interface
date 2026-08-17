# profile / asteroid_gravity

## Folder purpose

Zeffiro **startup profile** for a two-compartment asteroid (bounding box + body) with **gravity** lead-field recipes. Density `rho` is the active tissue parameter; electrical `sigma` and electrode CEM rows are Off.

## Main contents

| File | Role |
|------|------|
| `zeffiro_segmentation.ini` | Tags `c1` (Box, `_sources == -1` PML/bounding box, ρ=0), `c2` (Asteroid, unconstrained field, ρ=2000) |
| `zeffiro_parameters.ini` | `rho` On; `sigma` and electrode impedance/radii Off |
| `zeffiro_forward_simulation.ini` | Gravity scalar/vector and gravity-gradient scalar/vector (`zef_gravity_*`) — no EEG/MEG |
| `zeffiro_plugins.ini` | SESAME, wireframe creator; drops Kalman, NSE, SL1, DTI, EXP Lasso; adds EXP IAS RAMUS; GMM App (JL) only |
| `zeffiro_init.ini` | Extra `zef` fields after `zef_init` |

No `.m` files — INI data only.

## Code functionality

- Startup / profile switch reads these INIs into `zef` (plugins list, parameter definitions, forward method strings).
- Forward table **Run script** `eval`s gravity lead-field builders, not EEG/MEG.
- Plugin set favors gravity / SESAME / wireframe workflows over head-oriented inverse stacks.

## Workflow context

Use when meshing an asteroid body and assembling gravity (or gravity-gradient) lead fields. Sample surfaces: `data/itokawa_model/`. Saved project: `data/example_projects/asteroid_gravity_project.mat`. Sibling profile `asteroid_radar` shares the same gravity physics in its INIs; the distinction is example project and surfaces, not a different PDE here.

## Usage instructions

1. Segmentation tool **Profile:** → `asteroid_gravity`, then Apply plugin/parameter INIs and Mesh tool **Update from profile**, **or** set **Profile name** in **Settings → System settings** (`zeffiro_interface.ini`) and restart.
2. Import Itokawa (or other) surfaces; set `rho` as needed.
3. Mesh tool → select a Gravity **Run script** row.
4. Optional: **Multi-tools → Wireframe creator tool**; SESAME from Inverse tools.

Parent overview: [`../README.md`](../README.md).

## Important notes

- Changing **Profile:** alone only stores `zef.profile_name` — reload INIs explicitly.
- No `zeffiro_interface.ini` in this folder (lives only in `profile/`).
- `FindSyntheticGravityData` is related by physics but is **not** listed in this profile’s plugins INI.

## Developer guidance

Keep the five-INI layout aligned with other `profile/*` folders. When adding gravity-related plugins or forward rows, document defaults here and wire start scripts under `tools/plugins/` / `src/forward/`. Parent inventory: [`../README.md`](../README.md).
