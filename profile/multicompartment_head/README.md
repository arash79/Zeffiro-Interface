# Profile: Multicompartment Head

This is the **main neuroimaging profile** for Zeffiro Interface. It targets **EEG**, **MEG**, **EIT**, and **tES** (transcranial electrical stimulation) forward and inverse problems with a flexible multicompartment head model. No predefined compartment list is imposed; users define their own mesh and compartments.

## Use Case

- Electroencephalography (EEG) and magnetoencephalography (MEG) source reconstruction.
- Electrical impedance tomography (EIT) and transcranial electrical stimulation (tES) modelling.
- Isotropic and anisotropic electrical conductivity.
- Full plugin set: Kalman filter, NSE tool, DTI conductivity, synthetic extended source patch, etc.

## Files in This Profile

| File | Purpose |
|------|--------|
| **zeffiro_init.ini** | Default plot size; modalities `EEG`, `MEG magnetometer`, `MEG gradiometers`; **CEM electrode creation** callback `@zef_cem_electrode` for patch sensors. |
| **zeffiro_parameters.ini** | Conductivity (`sigma`), mass density (`rho`), permittivity (`epsilon`), permeability (`mu`), filter labels (`filtered_tetra`), electrode impedance and radii, thermal conductivity (`kappa`), finite element condition number. Electrical conductivity is primary for EEG/MEG/EIT/tES. |
| **zeffiro_forward_simulation.ini** | Ten lead-field options: EEG, MEG (magnetometers, gradiometers), EIT, tES; each in **isotropic** and **anisotropic** electrical conductivity variants. Functions follow the pattern `zef_*_lead_field_isotropic;` and `zef_*_lead_field_anisotropic;`. |
| **zeffiro_plugins.ini** | Full menu: multi lead field, filter, topography, RAMUS/IAS/EXP, standardized L1/L2 (Lasso), MNE, beamformer, CSM, MUSIC, GMM (SP and JL), lead field processing, reconstruction, dipole scan, data bank, dynamical plot queue, preconditioned relaxation, synthetic source legacy, GitHub pusher, **Kalman**, **NSE tool**, **synthetic extended source patch**, **DTI conductivity tool**. Includes a test plugin item. |
| **zeffiro_segmentation.ini** | **Empty** compartment lists (no default tags, colors, or names). The **Parameter setting** row is tied to **sigma** (electrical conductivity). Users define compartments and values when building their own head mesh. |

## Notes

- **Compartments:** Left blank so that any segmentation (e.g. skin, skull, CSF, grey/white matter, custom regions) can be defined by the user.
- **Plugins:** This profile includes the widest set of tools (Kalman, NSE, DTI, extended source patch) compared to legacy and NSE-only variants.
- **Forward simulation:** Choose isotropic or anisotropic lead fields depending on whether conductivity is scalar or tensor in your mesh.

For the overall profile system and INI format, see the parent [../README.md](../README.md).
