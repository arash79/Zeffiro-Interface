## Folder purpose

Recursively applied MUSIC: peel successive dipoles from the signal subspace (`zef.RAPMUSIC_n_dipoles`, default 8). Use for a few discrete sources when plain MUSIC’s single scan is not enough. No `inverse.*Inverter`. Registry id `legacy_rap_music` dispatches `RAP_MUSIC_iteration`.

## Main contents

| File | Role |
|------|------|
| `RAPMUSIC_start.m` | Constructs `RAPMUSIC_app` |
| `RAP_MUSIC_iteration.m` | Session wrapper (waitbar, `zef_processLeadfields`) |
| `zef_rap_music_scan.m` | RAP projector peel + oriented topography + LS amplitude |
| `zef_subspace_corr.m` | Principal-angle / orientation helper |
| `RAPMUSIC_app.mlapp` | Window layout |

## Code functionality

Each peel maximises the principal subspace correlation of \(P L(r)\) against \(P\Phi_s\), where \(P=I-QQ'\) is the RAP projector onto the orthogonal complement of already-found topographies \(A\) (Mosher & Leahy RAP-MUSIC). The found source is one column \(a=L(r)u\), not an elementwise \(L.*u'\) block. Orientations are stored per dipole. Amplitude is \(A^\top(AA^\top+S)^{-1}f\) (ridge equivalent to tall LS). Start stores `zef.reconstruction` and `zef.reconstruction_information`.

## Workflow context

**Not** in any profile `zeffiro_plugins.ini`. Open from MATLAB with plugins on the path (`RAPMUSIC_start`). Cluster id `legacy_rap_music` calls `RAP_MUSIC_iteration` directly. Needs `zef.L`, interpolation, `zef.source_direction_mode`, `zef.measurements`, SNR (`inv_snr`, `inv_prior_over_measurement_db`), and `RAPMUSIC_*` knobs.

## Usage instructions

```matlab
RAPMUSIC_start
```

Window title: `ZEFFIRO Interface: RAP-MUSIC`. StartButton:

```matlab
[zef.reconstruction, ~, zef.reconstruction_information] = RAP_MUSIC_iteration;
```

## Important notes

- Not in default / asteroid / `_legacy` / `_nse` INIs.
- Reads `zef` from the base workspace.
- Plugin `L` after `zef_processLeadfields` is **blocked** (x-block, y-block, z-block). `L_ind` is `zef_blocked_source_index(n_interp, mode)`: `n_interp` rows `[k, k+n, k+2n]`. Do not use `length(unexpanded s_ind_1)/3` — that list already has length `n_interp`.
- `n_dipoles` is capped by the numerical rank of the sample covariance. A single time sample can support only one peel.

## Developer guidance

Keep `zef_rap_music_scan` free of `evalin` so unit tests can drive it. Do not rebuild `A` from raw triplets times a stacked orientation vector — that mixed blocked `L_ind` order with xyz-per-dipole `orj`.
