# profile / multicompartment_head

## Folder purpose

Default Zeffiro **startup profile** for EEG/MEG/EIT/tES multi-compartment head models. `profile/zeffiro_interface.ini` sets `profile_name` to this folder.

## Main contents

| File | Loaded by | This profile |
|------|-----------|--------------|
| `zeffiro_plugins.ini` | `zef_plugin` | Full EEG/MEG inverse set: SL1, EXP Lasso, dual GMM (SP/JL), Kalman, NSE, DTI, synthetic source patch. **No** `exp_ias_map_estimation_multires` |
| `zeffiro_init.ini` | `zef_apply_init_profile` | Initial `zef` fields after `zef_init` |
| `zeffiro_segmentation.ini` | `zef_init_compartments` | **Header only** (empty compartment table) |
| `zeffiro_parameters.ini` | `zef_apply_parameter_profile` | `sigma` On (0.33 S/m); `rho` Off; sensor CEM radii/impedance On |
| `zeffiro_forward_simulation.ini` | Mesh tool table | Isotropic and anisotropic EEG, MEG magnetometer/gradiometer, EIT, tES (`zef_*_lead_field_*`) |

No `.m` files — INI data only. No per-folder `zeffiro_interface.ini` (root `profile/` only).

## Code functionality

- Startup / profile switch loads plugins, parameters, segmentation template, and forward **Run script** names into `zef`.
- Segmentation INI is an empty template — anatomy comes from import (e.g. `data/segmentations/multicompartment_head_project/`).
- Plugin set is the broadest default head inventory (Kalman, NSE, DTI, EXP Lasso, dual GMM).

## Workflow context

Use for standard EEG/MEG/EIT/tES head pipelines. Prefer `_legacy` when you want a pre-seeded 25-compartment table; `_nse` when NSE/microvessel parameter rows should be emphasized; asteroid profiles for gravity/density instead of head modalities.

## Usage instructions

1. Launch Zeffiro (default `profile_name` already points here), **or** set **Profile:** → `multicompartment_head` and Apply plugin/parameter INIs + Mesh tool **Update from profile**.
2. Import compartments / open an example head project.
3. Set `sigma` and sensors; run a forward **Run script** row; open inverse tools from the menu.

Parent overview: [`../README.md`](../README.md).

## Important notes

- The segmentation-tool **Profile:** dropdown only stores `zef.profile_name` — it does not reload INIs by itself.
- `zef_update` can overwrite an unsaved dropdown change.

## Developer guidance

Keep CSV column order consistent with other `profile/*/zeffiro_*.ini` files. Plugin inventory for this default set: `plugins/README.md`. Parent: [`../README.md`](../README.md).
