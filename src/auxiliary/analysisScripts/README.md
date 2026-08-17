# src/auxiliary/analysisScripts

## Folder purpose

One-off **batch / study scripts** from older papers (GMM of reconstructions, SNR tests, databank cleanup). They assume a live `zef` with `zef.dataBank` and are **not** wired to any menu.

## Main contents

| File | Kind | Notes |
|------|------|--------|
| `makeReconstructions.m` / `makeReconstructions_forAllData.m` | scripts | Write `zef.reconstruction` from databank entries |
| `makeGMM.m` | script | Fit GMMs (`gmm_opt=1:3`) |
| `zef_insideGMM.m` | function | Points inside GMM components |
| `zef_GMM_resection_volume.m` | function | Overlap of GMM with a resection volume |
| `zef_distance_to_resection.m` | function | Duplicate of `src/auxiliary/zef_distance_to_resection.m` |
| `snrTest.m`, `snrTestImageP1.m`, `snrTestImageP2.m` | scripts | SNR figures; hard-coded `p1`/`p2` |
| `p_snr_makeAll.m`, `p_outputNew.m`, `p_outputNew_subplot.m`, `gmm_subplot.m` | scripts | Patient-labelled figure dumps |
| `dataBank_delete_x.m` | script | Deletes databank entries of type `'gmm'` |

## Code functionality

- Scripts mutate `zef` in the base workspace (reconstructions, GMM fits, SNR figures, databank deletes).
- Helper functions support GMM–resection overlap and inside-component tests used by those studies.
- Paths and patient labels are often hard-coded for the original paper runs.

## Workflow context

Historical analysis of databank-stored reconstructions and GMM clusters. Prefer `+examples/+studies` and `zef_inverse_run` for new work.

## Usage instructions

1. Start Zeffiro and load a project / databank with the expected entries.
2. `cd` or `addpath` this folder if needed; run a chosen script from MATLAB (e.g. `makeReconstructions`, `makeGMM`, `snrTest`).
3. Inspect `zef.reconstruction`, figures, or databank side effects after each run.

## Important notes

- Not on any menu; unsafe to run blindly (databank deletes, hard-coded patient paths).
- `zef_distance_to_resection.m` duplicates a sibling under `src/auxiliary/`.
- Scripts expect Statistics Toolbox / GMM tooling where they fit mixtures.

## Developer guidance

Do not wire these into profile plugin INIs. Extract reusable logic into supported packages (`+examples`, `utilities`) rather than extending these paper scripts in place. Prefer parameterized drivers over hard-coded `p1`/`p2` paths.
