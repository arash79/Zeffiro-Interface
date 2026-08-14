# SESAME / m

Asteroid Inverse tools → **SESAME**. Sequential Monte Carlo over a small number of equivalent dipoles (Poisson prior on count, neighbour-graph location moves). Not in the default head INI. No `inverse.*Inverter`.

User manual: [parent README](../README.md).

| File | Role |
|------|------|
| `SESAME_App_run` | INI callback. Wires Start to `SESAME_inversion([])` |
| `zef_init_SESAME` / `zef_update_SESAME` | Defaults / widgets → `SESAME_*` and `inv_*` |
| `SESAME_core_check` | `webread` `inverse_SESAME.m` from SESAME_core **if missing** (this tree already ships it) |
| `SESAME_inversion` | Wrapper: neighbours, frames, `cfg.noise_std` from `SESAME_snr`. Uses `s_ind_1` before it is assigned (as written) |
| `inverse_SESAME` | SMC core: anneal likelihood exponent, birth/death RJ (`Q_birth=1/3`, `Q_death=1/20`), ESS resampling, neighbour moves. Does not read `zef` |
| `SESAMEneighbours` | Spatial neighbour graph on `source_positions` |
| `SESAME_plot_movie` | Dipoles via `zef_plot_source(2)` |
