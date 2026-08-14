# Study / databank scripts (`src/auxiliary/analysisScripts`)

One-off batch scripts from older papers (GMM of reconstructions, SNR tests, databank cleanup). They assume a live `zef` with `zef.dataBank` and are **not** wired to any menu.

| File | Kind | Notes |
|------|------|--------|
| `makeReconstructions.m` / `makeReconstructions_forAllData.m` | **scripts** | Write `zef.reconstruction` from databank entries |
| `makeGMM.m` | **script** | Fit GMMs (`gmm_opt=1:3`) |
| `zef_insideGMM.m` | function | Points inside GMM components |
| `zef_GMM_resection_volume.m` | function | Overlap of GMM with a resection volume |
| `zef_distance_to_resection.m` | function | Duplicate of `src/auxiliary/zef_distance_to_resection.m` |
| `snrTest.m`, `snrTestImageP1.m`, `snrTestImageP2.m` | **scripts** | SNR figures; hard-coded `p1`/`p2` |
| `p_snr_makeAll.m`, `p_outputNew.m`, `p_outputNew_subplot.m`, `gmm_subplot.m` | **scripts** | Patient-labelled figure dumps |
| `dataBank_delete_x.m` | **script** | Deletes databank entries of type `'gmm'` |

Prefer `+examples/+studies` and `zef_inverse_run` for new work. These scripts mutate `zef` in the base workspace.
