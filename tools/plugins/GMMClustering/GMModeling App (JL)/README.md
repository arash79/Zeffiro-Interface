# JL Gaussian-mixture GUI

This folder is the **Gaussian Mixture Model (JL)** Inverse-tools entry. The INI callback is `GMModelApp_start` in `m/BasicGMM/` (asteroid profiles label the same callback **GMM App**).

It clusters an **existing** `zef.reconstruction` into Gaussian components so you can plot equivalent dipoles. It does **not** assemble `L` or invert. `plugins.ClassGMM` is unused from this GUI.

**Start** (from `GMModelApp_start`) calls `zef_AdvGMModeling` unless both advanced-option flags in `zef.GMM.parameters` are `'1'`, in which case it calls `zef_GMModeling_K`. Needs Statistics Toolbox (`fitgmdist`). Outputs go to `zef.GMM.model` / `.dipoles` / `.amplitudes` / `.time_variables` — not `zef.reconstruction`.

| Subfolder | Role |
|-----------|------|
| `m/BasicGMM/` | Start script, `zef_GMModeling_K`, plot/export |
| `m/AdvancedGMM/` | `zef_AdvGMModeling` plus vendor MathWorks GMM helpers (not Zeffiro APIs) |
| `mlapp/` | `GMModelApp.mlapp` and option/plot/export apps |

Menu, Start branch, and parameter list: [../README.md](../README.md).
