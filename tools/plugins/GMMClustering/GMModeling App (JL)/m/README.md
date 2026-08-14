# JL GMM — first-party MATLAB (`m/`)

This folder’s children are the only first-party solvers for Inverse tools → **Gaussian Mixture Model (JL)**.

| Subfolder | Start from the app |
|-----------|--------------------|
| `BasicGMM/` | INI callback `GMModelApp_start`; **Start** → `zef_GMModeling_K` when both advanced flags are `'1'` |
| `AdvancedGMM/` | **Start** → `zef_AdvGMModeling` otherwise. Vendor MathWorks helpers (`estep`, `FitAdvGMM`, …) live here too — not Zeffiro APIs |

Plot/export helpers sit next to `GMModelApp_start`. Plugin manual (menu, outputs, Statistics Toolbox): [../../README.md](../../README.md).
