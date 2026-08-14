# `multicompartment_head_legacy`

Head profile whose segmentation INI is **pre-seeded** with a 25-compartment table (skin, skull, CSF, grey/white matter, plus Detail 1–22). Use this when you want default tissue names and σ values without importing a segmentation first.

Switch: segmentation tool **Profile:** dropdown, then apply INIs (dropdown alone does not reload files). Parent: [`profile/README.md`](../README.md).

## How it differs from `multicompartment_head`

| File | Difference |
|------|------------|
| `zeffiro_segmentation.ini` | Populated tags `sc,sk,c,g,w,d1…d22` with colours, activity (`g` unconstrained field, `w` active surface), and σ (skin 0.43, skull 0.0064, CSF 1.79, grey 0.33, white 0.14). |
| `zeffiro_plugins.ini` | Adds **EXP IAS RAMUS** (`exp_ias_map_estimation_multires`). Drops SL1, EXP Lasso, DTI, synthetic source patch. Keeps dual GMM, Kalman, NSE. |
| `zeffiro_parameters.ini` | Same σ-on / ρ-off layout as the default head profile. |
| `zeffiro_forward_simulation.ini` | Same EEG/MEG/EIT/tES isotropic+anisotropic table as the default head. |
