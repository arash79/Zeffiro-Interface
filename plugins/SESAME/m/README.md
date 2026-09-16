## Folder purpose

Inverse tools → **SESAME** (every shipped profile): sequential Monte Carlo over a small number of equivalent dipoles (Poisson prior on count, neighbour-graph location moves). No `inverse.*Inverter`.

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

Listed on every shipped profile INI. Parent README is the user manual. Needs lead field, measurements, and `SESAME_*` / inverse time-band settings.

## Usage instructions

Open from Inverse tools → **SESAME**, or:

```matlab
SESAME_App_run
% Start runs:
SESAME_inversion([])
```

## Important notes

- Source nodes are `unique(zef.source_interpolation_ind{1})`; progress uses `zef_waitbar`.
- Core does not read `zef`; all session bridging is in the wrapper.
- `SESAME_core_check` may hit the network if the core file is deleted.

## Developer guidance

Keep SMC math in `inverse_SESAME.m` free of `zef` globals. Prefer shipping the core file rather than depending on `webread`.
