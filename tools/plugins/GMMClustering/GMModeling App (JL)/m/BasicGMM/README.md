# JL GMM — basic fitter (`BasicGMM`)

This is the **Gaussian Mixture Model (JL)** Inverse-tools entry. `GMModelApp_start` (INI callback) opens `GMModelApp.mlapp` and wires **Start**. It clusters an **existing** `zef.reconstruction`; it does not assemble `L` or invert.

When the advanced-option flags in `zef.GMM.parameters` are both `'1'`, Start calls `zef_GMModeling_K` (this folder). Otherwise it calls `zef_AdvGMModeling` under `AdvancedGMM/`. `zef_GMModeling` (plain `fitgmdist`, no `_K`) is kept here but is **not** the Start button.

Plot / export helpers (`zef_PlotGMModel`, amplitude plots, table export) write figures and cluster tables onto `zef.GMM.*`. They do not overwrite `zef.reconstruction`.

Needs Statistics Toolbox (`fitgmdist`). Plugin manual (menu, Start branch, outputs): [../../../README.md](../../../README.md).
