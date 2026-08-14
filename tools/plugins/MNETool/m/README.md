# MNETool / m

Inverse tools → **Minimum norm estimation tool**. Weighted MNE and the classical noise-normalized maps (dSPM, sLORETA) on `zef.L`. The class path is `inverse.MNEInverter` / `CSMInverter` via `zef_inverse_run` — this folder does not construct those objects.

User manual: [parent README](../README.md).

| File | Role |
|------|------|
| `zef_minimum_norm_estimation.m` | INI callback |
| `zef_mne_tool_start.m` | Window + `zef_init_mne`; does not rebind Start |
| `zef_mne_tool_window.m` | GUIDE dump; Start → update + `zef_find_mne_reconstruction(zef)` |
| `zef_init_mne.m` / `zef_update_mne.m` | Defaults / widgets → `mne_*` |
| `zef_find_mne_reconstruction.m` | Solver (`mne_type` 1 MNE, 2 dSPM, 3 sLORETA, 4 wMNE) |
| `zef_mne_tool_export.m` | GUIDE export dump; not the live start path |
