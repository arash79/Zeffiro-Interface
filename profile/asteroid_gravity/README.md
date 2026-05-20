# Profile: Asteroid Gravity

This profile configures Zeffiro Interface for **gravity and gravity-gradient forward and inverse problems**, typically used in asteroid or planetary body modelling. The physics is scalar and vector fields (gravity potential and gradient); the available lead fields are gravity and gravity-gradient types only.

## Use Case

- Gravity field inversion (e.g. from orbit or surface measurements).
- Gravity gradient inversion (tensor or component-wise).
- Two-compartment setup: a surrounding **Box** (domain) and an **Asteroid** (or other body) with configurable mass density.

## Files in This Profile

| File | Purpose |
|------|--------|
| **zeffiro_init.ini** | Default plot size and imaging modalities: `Scalar field`, `Vector field`, `Vector field gradient`. No EEG/MEG; no CEM electrode creation. |
| **zeffiro_parameters.ini** | Physical parameters: electrical conductivity (`sigma`), mass density (`rho`), dielectric permittivity (`epsilon`), magnetic permeability (`mu`), electrode dimensions and impedance, thermal conductivity (`kappa`), finite element condition number. Mass density is the primary parameter for gravity. |
| **zeffiro_forward_simulation.ini** | Four lead-field options: gravity (scalar), gravity (vector), gravity gradient (scalar), gravity gradient (vector). Corresponding functions: `zef_gravity_lead_field_scalar`, `zef_gravity_lead_field_vector`, `zef_gravity_gradient_lead_field_*`. |
| **zeffiro_plugins.ini** | Standard tool set: multi lead field, filter, topography, RAMUS/IAS/EXP inversions, MNE, beamformer, dipole scan, data bank, reconstruction tool, SESAME, preconditioned relaxation, synthetic source legacy, GitHub pusher, wireframe creator. |
| **zeffiro_segmentation.ini** | Two compartments: **Box** and **Asteroid**. Default parameter setting row uses **rho** (mass density) with values `0` and `2000` (e.g. kg/m³). Activity and colors are set per compartment. |

## Compartment and Parameter Notes

- **Compartment tags:** `c1` (Box), `c2` (Asteroid).
- **Parameter setting:** The segmentation profile ties the **Parameter setting** row to **rho** (mass density), which drives the gravity forward model.
- Electrode-related parameters (impedance, inner/outer radius) are present for consistency but typically less relevant for pure gravity inversion.

For the overall profile system and INI format, see the parent [../README.md](../README.md).
