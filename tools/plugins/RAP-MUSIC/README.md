# tools/plugins/RAP-MUSIC
## Folder purpose

Recursively applied MUSIC: peel successive dipoles from the signal subspace (`zef.RAPMUSIC_n_dipoles`, default 8). Use for a few discrete sources when plain MUSIC’s single scan is not enough. No `inverse.*Inverter`. Registry id `legacy_rap_music` dispatches `RAP_MUSIC_iteration`.

## Main contents

| File | Role |
|------|------|
| `RAPMUSIC_start.m` | Constructs `RAPMUSIC_app` |
| `RAP_MUSIC_iteration.m` | Solver (uses `zef_subspace_corr`) |
| `zef_subspace_corr.m` | Subspace correlation helper |
| `RAPMUSIC_app.mlapp` | Window layout |

## Code functionality

Each peel finds a dipole orientation/location from the signal subspace. As written, each peel overwrites `orj` instead of concatenating (concatenate line commented), so `A_mat` applies the **last** orientation to every found column. Start button assigns only `zef.reconstruction`; extra outputs `Var_loc` and `reconstruction_information` are discarded.

## Workflow context

**Not** in any profile `zeffiro_plugins.ini`. Call from MATLAB with plugins on the path. Needs `zef.L`, interpolation, `zef.source_direction_mode`, `zef.measurements`, SNR (`inv_snr`, `inv_prior_over_measurement_db`), and `RAPMUSIC_*` knobs.

## Usage instructions

```matlab
RAPMUSIC_start
```

Window title: `ZEFFIRO Interface: RAP-MUSIC`. StartButton:

```matlab
zef.reconstruction = RAP_MUSIC_iteration;
```

## Important notes

- Not in default / asteroid / `_legacy` / `_nse` INIs.
- Reads `zef` from the base workspace.
- Orientation overwrite bug is documented as written — do not assume multi-dipole orientations are independent.

## Developer guidance

Fix orientation accumulation before treating multi-dipole results as reliable. Optionally capture `[reconstruction, Var_loc, reconstruction_information]` on Start. Register in INI only after Start wiring is validated.
