## Folder purpose

Spatial-filter beamformer plugin (LCMV, unit-noise-gain, unit-gain, scalar UNG) that scans the source grid. Use it for covariance-based localization rather than a distributed Tikhonov map.

## Main contents

- Start: `zef_beamformer_start.m` → `zef_beamformer_window`
- Solver: `zef_beamformer.m`
- Layout: `zef_beamformer_app.mlapp`

## Code functionality

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

What each **type** does after that covariance `C` (implementation in `zef_beamformer.m`):

| `bf_type` | Label | Filter |
|-----------|-------|--------|
| 1 | LCMV | Whiten with \(C^{-1/2}\), then \(z = (L^\top L + \lambda I)^{-1} L^\top f\) (or `pinv`) per source triplet |
| 2 | Unit noise gain | Same LCMV-style weights, then column-normalize \(\|w\|=1\) (Borgiotti–Kaplan) and \(z = w^\top f\). On free-orientation sources with `L_reg_type==2` and Matrix/Column normalization, the `else` branch multiplies a `weights` that this iteration has not assigned |
| 3 | Unit-gain constraint | After \(C^{-1/2}\) whitening, orientation = smallest eigenvector of \(L^\top L\), then type-1 LCMV on that 1-column \(L\), times the orientation |
| 4 | Unit noise gain scalar | **No** \(C^{-1/2}\) on \(f\). \(L \leftarrow C\setminus L\), orientation from `eigs(L'L, L'C^{-1}L)`, then \(z = (L^\top L)^{-1/2} L^\top f\) times that orientation |

Constrained-field nodes (`procFile.s_ind_4`, Mesh-tool Directions = Normal) use a single lead-field column in every type. `Var_loc` stores `trace(z z')` per source as a scalar “location strength”.

Needs: `zef.L`, interpolation, `zef.source_direction_mode`, `zef.measurements`; SNR `zef.inv_snr` → `10^(-inv_snr/20)`; covariance `zef.cov_type`, `zef.inv_cov_lambda`; lead-field ridge `zef.inv_leadfield_lambda` / `zef.L_reg_type`; frames `zef.number_of_frames`, `inv_time_*`, band edges.

Writes: `zef.reconstruction` and `zef.reconstruction_information` (tags `Beamformer/LCMV`, `/UNG`, `/UG`, `/UNGsc`); optionally `zef.bf_var_loc`.

## Workflow context

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **Beamformer** |
| `_legacy`, `_nse`, asteroid_radar, asteroid_gravity | same |

INI callback: `zef_beamformer_start`. Window title: `ZEFFIRO Interface: Beamformer`.

This plugin does **not** construct `inverse.BeamformerInverter`. Class id `beamformer` (and `legacy_beamformer`) is a separate `zef_inverse_run` track.

## Usage instructions

1. Open Inverse tools → Beamformer.
2. Choose beamformer type, covariance type, lead-field regularization, and normalization.
3. Press Start; inspect `zef.reconstruction` (and optionally `zef.bf_var_loc`).

## Important notes

- Covariance type 0 disables the λ box but is not a listed dropdown item.
- Unit noise gain (`bf_type` 2) has a known unassigned-`weights` path for free-orientation + `L_reg_type==2` + Matrix/Column normalization.
- Scalar UNG does not whiten `f` with \(C^{-1/2}\).

## Developer guidance

Keep menu callback `zef_beamformer_start` and reconstruction tags (`Beamformer/LCMV`, `/UNG`, `/UG`, `/UNGsc`) stable. Do not conflate this plugin with the `beamformer` / `legacy_beamformer` `zef_inverse_run` class path.
