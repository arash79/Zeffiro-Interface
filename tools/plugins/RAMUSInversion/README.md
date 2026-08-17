## Folder purpose

RAMUS (randomized multiresolution source space) hierarchical Bayes: IAS-style updates on several sparse coarsenings of the source grid, then combine. Use it for focal sources when single-resolution IAS is too smooth.

## Main contents

- Start: `m/zef_ramus_inversion_tool.m` → `zef_ramus_window`
- Solver: `m/zef_ramus_iteration.m`

## Code functionality

**Start** (`zef.h_ramus_start`) Callback:

```matlab
zef_update_ramus_inversion_tool; [zef.reconstruction, zef.reconstruction_information] = zef_ramus_iteration(zef);
```

**Create multiresolution decomposition** (`zef.h_ramus_make_multires_dec`) builds `zef.ramus_multires_dec` / `_ind` / `_count` via `zef_make_multires_dec` — run that before Start if those fields are empty.

Each frame runs IAS MAP on every pair `(decomposition, level)`. Coarse lead-field columns are `L(:, mr_dec)` (xyz stacked when direction mode is 1 or 2). The inner step is the same weighted MNE as IAS type 1:

\[
z = \sqrt{\theta}\, L^\top (L\,\mathrm{diag}(\theta)\,L^\top + \sigma^2 I)^{-1} f
\]

then \(\theta\) is updated from the inverse-gamma or gamma hyperprior (`zef.inv_hyperprior`). After `n_iter(j)` steps the coarse `z` is scattered back with `mr_ind` and **summed**. The frame is then divided by `n_multires * n_decompositions * sum(sparsity_factor.^[0:n_multires-1])`. A level with `n_iter(j)==0` contributes zeros and zeros that level’s weight. `ramus_init_guess_mode == 2` (or the first decomposition) rebuilds `θ` from the hyperprior; otherwise `θ` is indexed from the previous coarsening.

The window label **IAS MAP iterations:** writes `zef.ramus_multires_n_iter` (scalar is replicated to every level). `zef.ramus_n_map_iterations` is initialized to 25 and read into an unused variable.

Decompositions come from Mesh-tool / RAMUS **Create multiresolution decomposition** → `zef_make_multires_dec` (`src/forward/lead_field/`): level `k=1` is coarsest (`floor(n / sparsity^(n_levels-1))` random sources); the last level is the identity.

Needs: `zef.L`, interpolation, `zef.source_direction_mode`, `zef.measurements`; SNR `zef.ramus_snr` → `10^(-ramus_snr/20)`; frames `zef.ramus_number_of_frames`, `ramus_time_*`, `ramus_sampling_frequency`, band edges (solver copies them onto `zef.inv_*`); multires `zef.ramus_multires_n_levels`, `ramus_multires_sparsity`, `ramus_multires_n_decompositions`, `ramus_multires_n_iter`; hyperprior `zef.ramus_hyperprior` plus `zef.inv_prior_over_measurement_db`.

Writes: `zef.reconstruction` after post-process / peak-norm; `zef.reconstruction_information` with tag `RAMUS`.

## Workflow context

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **RAMUS Inversion** |
| `_legacy`, `_nse`, asteroid_radar, asteroid_gravity | same |

INI callback: `zef_ramus_inversion_tool`. Window title: `ZEFFIRO Interface: RAMUS Inversion`.

This plugin does **not** construct `inverse.RAMUSInverter`. Class id `ramus` (and `legacy_ramus`) is a separate `zef_inverse_run` track. The class path still needs a multiresolution decomposition (`zef_make_multires_dec`) first.

## Usage instructions

1. Open Inverse tools → RAMUS Inversion.
2. Create multiresolution decomposition if `ramus_multires_*` fields are empty.
3. Set levels, sparsity, decompositions, and iteration counts; press Start.

## Important notes

- Run Create multiresolution decomposition before Start when fields are empty.
- `zef.ramus_n_map_iterations` is initialized but unused; the live iteration count is `ramus_multires_n_iter`.
- Levels with `n_iter(j)==0` contribute zeros and zero weight.

## Developer guidance

Preserve callback `zef_ramus_inversion_tool`, tag `RAMUS`, and dependency on `zef_make_multires_dec`. Do not conflate with `ramus` / `legacy_ramus` class ids.
