# Beamformer

Spatial filters (LCMV, unit-noise-gain, unit-gain, scalar UNG) that scan the source grid. Use it when you want a covariance-based localization rather than a distributed Tikhonov map.

This plugin does **not** construct `inverse.BeamformerInverter`. Class id `beamformer` (and `legacy_beamformer`) is a separate `zef_inverse_run` track.

## Menu

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **Beamformer** |
| `_legacy`, `_nse`, asteroid_radar, asteroid_gravity | same |

INI callback: `zef_beamformer_start`.

Window title: `ZEFFIRO Interface: Beamformer`.

## Run the solver

**StartButton** `ButtonPushedFcn` (depends on `estimation_attr`):

```matlab
if strcmp(zef.beamformer.estimation_attr.Value,'1')
    [zef.reconstruction,~, zef.reconstruction_information] = zef_beamformer(zef);
elseif strcmp(zef.beamformer.estimation_attr.Value,'2')
    [~,zef.reconstruction, zef.reconstruction_information] = zef_beamformer(zef);
else
    [zef.reconstruction,zef.bf_var_loc, zef.reconstruction_information] = zef_beamformer(zef);
end
```

Outputs of `zef_beamformer` are `[z, Var_loc, reconstruction_information]`. Value `'1'` stores power `z`; `'2'` stores location variance `Var_loc` as the reconstruction; otherwise both `z` and `zef.bf_var_loc`.

Types (wired in `zef_beamformer_window`): LCMV, Unit noise gain, Unit-gain constraint, Unit noise gain scalar → `zef.bf_type` 1–4. (The scalar label in the window is spelled `Unit nosie gain scalar beamformer`.)

Covariance dropdown (`zef.cov_type`):

| Value | Label | When `C` is built |
|-------|-------|-------------------|
| 1 | Full data, measurement based | Once, from all of `f_data`; ridge `λ·trace(C)/n_sensors · I` |
| 2 | Full data, basic | Once, from all of `f_data`; ridge `λ I` |
| 3 | Pointwise, measurement based | **Per frame** from that window; same trace ridge as 1 |
| 4 | Pointwise, basic | **Per frame**; ridge `λ I` |

`λ` is `zef.inv_cov_lambda`. The ValueChangedFcn disables the λ box when `cov_type==0`, which is not a listed item.

Lead-field regularization: Basic / Pseudoinverse (`zef.L_reg_type` 1/2). Normalization of `L` columns: Matrix / Column / Row / None.

## Needs

- `zef.L`, interpolation, `zef.source_direction_mode`
- `zef.measurements`
- SNR: `zef.inv_snr` → `10^(-inv_snr/20)`
- Covariance: `zef.cov_type`, `zef.inv_cov_lambda`; lead-field ridge `zef.inv_leadfield_lambda` / `zef.L_reg_type`
- Frames: `zef.number_of_frames`, `inv_time_*`, band edges

## Writes

- `zef.reconstruction` and `zef.reconstruction_information` (tags `Beamformer/LCMV`, `/UNG`, `/UG`, `/UNGsc`)
- Optionally `zef.bf_var_loc`

## Files

- Start: `zef_beamformer_start.m` → `zef_beamformer_window`
- Solver: `zef_beamformer.m`
- Layout: `zef_beamformer_app.mlapp`
