## Folder purpose

Asteroid Inverse tools → **SESAME**: sequential Monte Carlo over a small number of equivalent dipoles (Poisson prior on count, neighbour-graph location moves). Also on the default head INI. No `inverse.*Inverter`.

## Main contents

| File | Role |
|------|------|
| `SESAME_App_run.m` | INI callback; wires Start to `SESAME_inversion([])` |
| `zef_init_SESAME.m` / `zef_update_SESAME.m` | Defaults / widgets → `SESAME_*` and `inv_*` |
| `SESAME_core_check.m` | `webread` `inverse_SESAME.m` from SESAME_core if missing |
| `SESAME_inversion.m` | Wrapper: neighbours, frames, `cfg.noise_std` from `SESAME_snr` |
| `inverse_SESAME.m` | SMC core (does not read `zef`) |
| `SESAMEneighbours.m` | Spatial neighbour graph on `source_positions` |
| `SESAME_plot_movie.m` | Dipoles via `zef_plot_source(2)` |

## Code functionality

`inverse_SESAME`: anneal likelihood exponent, birth/death RJ (`Q_birth=1/3`, `Q_death=1/20`), ESS resampling, neighbour moves. `SESAME_inversion` builds cfg from widgets/SNR and runs the core over frames. This tree already ships `inverse_SESAME.m`; core_check only fetches if absent.

## Workflow context

Shown in some asteroid profiles, not `multicompartment_head`. Parent README is the user manual. Needs lead field, measurements, and `SESAME_*` / inverse time-band settings.

## Usage instructions

Open from the asteroid Inverse tools menu (where registered), or:

```matlab
SESAME_App_run
% Start runs:
SESAME_inversion([])
```

## Important notes

- `SESAME_inversion` uses `s_ind_1` before it is assigned (as written).
- Core does not read `zef`; all session bridging is in the wrapper.
- `SESAME_core_check` may hit the network if the core file is deleted.

## Developer guidance

Keep SMC math in `inverse_SESAME.m` free of `zef` globals. Fix `s_ind_1` ordering before relying on Start. Prefer shipping the core file rather than depending on `webread`.
