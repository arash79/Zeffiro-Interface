# SESAME — App Designer layouts

## Folder purpose

App Designer UI for **SESAME**: stochastic sampling of discrete dipole configurations (small numbers of equivalent dipoles with posterior samples rather than a dense grid map).

## Main contents

| File | Role |
|------|------|
| `SESAME_App.mlapp` | SESAME App (Start / Apply / Plot dipoles, SNR, sampler count) |
| `README.md` | This documentation |

Solvers: `plugins/SESAME/m/` (`SESAME_App_run`, `SESAME_inversion`, shipped `inverse_SESAME.m`, `SESAME_core_check`, plot helpers).

## Code functionality

`SESAME_App_run` opens this app (after optional `SESAME_core_check`), inits widgets, and wires **h_start** → `zef_update_SESAME; zef.reconstruction = SESAME_inversion([])`, **h_apply** → `zef_update_SESAME` only, **h_plot_dipoles** → `SESAME_plot_movie`. The sampler does not read `zef` directly; `SESAME_inversion` builds `cfg` / leadfield from the session and may assign `zef.SESAME` / `SESAME_time_serie` into the base workspace.

## Workflow context

Inverse tools → **SESAME** on asteroid_radar / asteroid_gravity (`SESAME_App_run`). Not on default / legacy / NSE head INIs. Registry id `legacy_sesame` also dispatches `SESAME_inversion`; there is no `inverse.*Inverter`.

## Usage instructions

```matlab
SESAME_App_run;   % opens SESAME_App.mlapp
% Title: ZEFFIRO Interface: SESAME App
```

1. On asteroid profiles: Inverse tools → SESAME.
2. Set SNR and sampler count; optionally Apply.
3. Press Start; use Plot dipoles for `SESAME_plot_movie`.

Edit UI only in App Designer.

## Important notes

- Core download via `SESAME_core_check` is a no-op when `m/inverse_SESAME.m` already exists.
- Parent README documents known issues in `SESAME_inversion` (e.g. `s_ind_1` / waitbar) — treat Start carefully until those are fixed.
- Default head profiles do not register this menu entry.

## Developer guidance

- Preserve callback `SESAME_App_run` and registry id `legacy_sesame` → `SESAME_inversion`.
- Keep Start / Apply / Plot handle names stable with `SESAME_App_run`.
- Lead-field node-wise reorder / `s_back_ind` contract belongs in `m/`, not the `.mlapp`.
