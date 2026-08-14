# `multicompartment_head` (default profile)

Default EEG/MEG/EIT/TES head profile. `profile/zeffiro_interface.ini` sets `profile_name` to this folder. Switch from the segmentation tool **Profile:** dropdown (`h_profile_name`); that only stores `zef.profile_name` — reload INIs from the matching Settings / Mesh tool **Update from profile** buttons, or restart Zeffiro.

Parent overview: [`profile/README.md`](../README.md).

## Five INIs

| File | Loaded by | This profile |
|------|-----------|--------------|
| `zeffiro_plugins.ini` | `zef_plugin` | Full EEG/MEG inverse set: SL1, EXP Lasso, dual GMM (SP/JL), Kalman, NSE, DTI, synthetic source patch. **No** `exp_ias_map_estimation_multires`. |
| `zeffiro_init.ini` | `zef_apply_init_profile` | Initial `zef` fields after `zef_init`. |
| `zeffiro_segmentation.ini` | `zef_init_compartments` | **Header only** (empty compartment table). Import `data/segmentations/multicompartment_head_project/` for anatomy. |
| `zeffiro_parameters.ini` | `zef_apply_parameter_profile` | `sigma` On (0.33 S/m). `rho` Off. Sensor CEM radii/impedance On. |
| `zeffiro_forward_simulation.ini` | Mesh tool table | Isotropic and anisotropic EEG, MEG magnetometer/gradiometer, EIT, tES (`zef_*_lead_field_*`). |

There is no `zeffiro_interface.ini` here — that file lives only in `profile/`.
