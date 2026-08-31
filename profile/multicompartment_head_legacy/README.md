# profile / multicompartment_head_legacy

## Folder purpose

Head **startup profile** whose segmentation INI is **pre-seeded** with a 25-compartment table (skin, skull, CSF, grey/white matter, plus Detail 1–22). Use when you want default tissue names and σ values without importing a segmentation first.

## Main contents

| File | Difference vs `multicompartment_head` |
|------|----------------------------------------|
| `zeffiro_segmentation.ini` | Populated tags `sc,sk,c,g,w,d1…d22` with colours, activity (`g` `_sources=1` Constrained field, `w` `_sources=3` Active surface), and σ (skin 0.43, skull 0.0064, CSF 1.79, grey 0.33, white 0.14) |
| `zeffiro_plugins.ini` | Adds **EXP IAS RAMUS** (`exp_ias_map_estimation_multires`); drops SL1, EXP Lasso, DTI, synthetic source patch; keeps dual GMM, Kalman, NSE |
| `zeffiro_parameters.ini` | Same σ-on / ρ-off layout as the default head profile |
| `zeffiro_forward_simulation.ini` | Same EEG/MEG/EIT/tES isotropic+anisotropic table as the default head |
| `zeffiro_init.ini` | Extra `zef` fields after `zef_init` |

## Code functionality

- Loads a ready-made compartment table into `zef` at init / Apply segmentation profile.
- Inverse menu includes GUIDE **EXP IAS RAMUS** instead of the unified EXP Lasso / SL1 / DTI / patch set used by the default head profile.
- Forward lead-field recipes match the default head profile.

## Workflow context

Prefer this profile for quick head setups without a `.zef` import, or when you need EXP IAS multiresolution on the menu. Prefer `multicompartment_head` for the full default plugin inventory and empty segmentation template.

## Usage instructions

1. Segmentation tool **Profile:** → `multicompartment_head_legacy`, then apply INIs (dropdown alone does not reload files), **or** set **Profile name** in System settings and restart.
2. Adjust compartment σ / activity as needed; mesh and run forward scripts.
3. Open **EXP IAS RAMUS** from Inverse tools when using the hierarchical multires MAP path.

Parent: [`../README.md`](../README.md).

## Important notes

- Pre-seeded Detail compartments are placeholders — replace geometry via import when doing real anatomy.
- Plugin differences matter: synthetic source patch and DTI are not on this profile’s INI.

## Developer guidance

When editing the 25-row table, keep tag/order conventions compatible with `zef_init_compartments`. Coordinate EXP IAS RAMUS callback names with `plugins/EXP/`. Parent: [`../README.md`](../README.md).
