# Profile: Asteroid Radar

This profile configures Zeffiro Interface for **radar and electromagnetic (EM) applications** in an asteroid or similar context. It extends the asteroid setup with **wireframe** and **dielectric** options (permittivity, filling) while reusing the same gravity-oriented lead fields as the asteroid_gravity profile. Suitable for EM/radar forward modelling and inversion when combined with the appropriate solvers.

## Use Case

- Radar or EM forward/inverse problems in a two-compartment geometry (Box, Asteroid).
- Use of wireframe representations with interpolated permittivity and filling.
- Dielectric permittivity and magnetic permeability are enabled in the parameter list (unlike the gravity-only profile, where some may be off by default).

## Files in This Profile

| File | Purpose |
|------|--------|
| **zeffiro_init.ini** | Same structure as asteroid_gravity: default plot size and modalities `Scalar field`, `Vector field`, `Vector field gradient`. |
| **zeffiro_parameters.ini** | Same base as asteroid_gravity plus: **Interpolated wireframe permittivity** (`wireframe_permittivity_vec`), **Interpolated wireframe filling** (`wireframe_filling_vec`). Dielectric permittivity and magnetic permeability are set **On** for segmentation. Electrode parameters use correct spelling (Electrode). |
| **zeffiro_forward_simulation.ini** | Identical to asteroid_gravity: gravity (scalar/vector) and gravity gradient (scalar/vector) lead fields. Radar-specific lead fields would be added here if implemented. |
| **zeffiro_plugins.ini** | Same tool set as asteroid_gravity: multi lead field, filter, topography, RAMUS/IAS/EXP, MNE, beamformer, dipole scan, data bank, reconstruction, SESAME, relaxation, synthetic source legacy, GitHub pusher, wireframe creator. |
| **zeffiro_segmentation.ini** | Same two compartments as asteroid_gravity: **Box** and **Asteroid** with compartment tags `c1`, `c2` and parameter setting **rho** (mass density). |

## Differences from Asteroid Gravity

- **Parameters:** Wireframe permittivity and filling are available; dielectric permittivity and magnetic permeability are turned on in the segmentation/parameter visibility.
- **Forward simulation:** Currently the same gravity/gravity-gradient entries; radar-specific lead fields can be added to this file when available.

For the overall profile system and INI format, see the parent [../README.md](../README.md).
