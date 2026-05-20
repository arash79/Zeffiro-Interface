# Profile: Multicompartment Head (NSE)

This profile extends the **multicompartment head** setup for workflows that combine **standard EEG/MEG/EIT/tES** with **NSE (e.g. Navier–Stokes or haemodynamic)** modelling. It adds NSE-specific parameters (microvessel density, NSE conductivity) and includes the NSE tool in the plugin list, while keeping the same forward lead fields and an empty compartment list like the main head profile.

## Use Case

- Neuroimaging plus haemodynamic or fluid-dynamics modelling (e.g. NSE tool).
- When microvessel density and NSE conductivity need to be defined per compartment or globally.
- Same flexibility as multicompartment_head for defining compartments, with extra parameters for NSE.

## Files in This Profile

| File | Purpose |
|------|--------|
| **zeffiro_init.ini** | Same as multicompartment_head: default plot size; modalities EEG, MEG magnetometer, MEG gradiometers; CEM electrode creation. |
| **zeffiro_parameters.ini** | Same as multicompartment_head **plus**: **Microvessel density** (`mvd_length`, default 200, unit Count/mm³, On for segmentation); **NSE conductivity** (`nse_sigma`, default 0 S/m, Off for segmentation). Order: sigma, mvd_length, nse_sigma, then rho, epsilon, mu, filtered_tetra, electrode*, kappa, condition number. |
| **zeffiro_forward_simulation.ini** | Identical to multicompartment_head: EEG, MEG, EIT, tES (isotropic and anisotropic). No NSE-specific lead field in this file; NSE is handled by the NSE tool and related solvers. |
| **zeffiro_plugins.ini** | Same as multicompartment_head_legacy: multi lead field, filter, topography, RAMUS/IAS/EXP, MNE, beamformer, CSM, MUSIC, GMM (SP and JL), lead field processing, reconstruction, dipole scan, data bank, dynamical plot queue, preconditioned relaxation, synthetic source legacy, GitHub pusher, **Kalman**, **NSE tool**. No DTI conductivity tool or synthetic extended source patch in this list. |
| **zeffiro_segmentation.ini** | **Empty** compartment lists (like multicompartment_head). Parameter setting row is **sigma**. Users define compartments when building the head mesh; they can then assign `mvd_length` and `nse_sigma` where relevant. |

## Differences from Multicompartment Head

- **Parameters:** Two extra rows in `zeffiro_parameters.ini`: **Microvessel density** (`mvd_length`) and **NSE conductivity** (`nse_sigma`). These are available in the parameter profile and segmentation/compartment dialogs for NSE workflows.
- **Plugins:** NSE tool is enabled; DTI conductivity and synthetic extended source patch are not listed in this profile’s plugin set.
- **Compartments:** No predefined list; same “user-defined” approach as the main multicompartment_head profile.

For the overall profile system and INI format, see the parent [../README.md](../README.md).
