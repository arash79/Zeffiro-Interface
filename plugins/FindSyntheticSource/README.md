# plugins/FindSyntheticSource

## Folder purpose

Places one or more dipoles, optionally with a Gaussian-envelope / Blackman–Harris time course, and writes **`zef.measurements` = L × sources + noise**.

## Main contents

| Path | Role |
|------|------|
| `m/find_synthetic_source.m` | Open App Designer window; wire buttons |
| `m/add_synthetic_source.m` / `remove_synthetic_source.m` | Manage `zef.synth_source_data` |
| `m/zef_update_fss.m` | Pack parameters → `inv_synth_source` + pulse cells |
| `m/zef_find_source.m` | Nearest-point dipoles through `L`; dB noise |
| `m/zef_generate_time_sequence.m` | Time course |
| `m/zef_plot_source_intensity.m` | Intensity plots |
| `src/gui/plot/zef_plot_source.m` | Shared 3-D arrows (type 1 synth / type 2 reconstructed) |
| `mlapp/` | App Designer UI |

## Code functionality

- Each source snaps to the nearest `zef.source_positions` point.
- Amplitude is nAm, scaled by `1e-3` in the forward product. Dipole noise and optional background noise are in dB (`10^(dB/20)`).
- Parameters per source: xyz, orientation, amplitude, noise STD (dB), sampling frequency, peak times, pulse amplitudes/length, oscillation frequency/phase, visual length/color. Shared: `zef.fss_bg_noise`, `zef.fss_time_val`.

## Workflow context

Built-in **Forward tools → Find synthetic source** (hardcoded in `zef_menu_tool.m`, every profile). The INI row **Find synthetic source legacy** opens `FindSyntheticSourceLegacy/` instead. Ball/ellipsoid patches: `FindSyntheticSourceLegacy_Patch/`. Curved-disk / SVD-orientation ROIs: `FindSyntheticSourceROI/`.

## Usage instructions

Menu callback:

```matlab
find_synthetic_source; zef = zef_update(zef);
```

Or:

```matlab
zef = find_synthetic_source(zef);
zef = zef_update_fss(zef);
[zef.time_sequence, zef.time_variable] = zef_generate_time_sequence(zef);
zef.measurements = zef_find_source(zef);
```

Buttons: Add/Remove source; Generate time sequence; Create synth data; Plot intensity / sources.

## Important notes

- Needs `zef.L` and `zef.source_positions`.
- Not a `zeffiro_plugins.ini` row for the non-legacy tool — menu wiring is in `zef_menu_tool.m`.

## Developer guidance

MATLAB file details: [`m/README.md`](m/README.md). Keep menu callback and App Designer start entry points aligned. Noise convention (dB) differs from the legacy linear-fraction tool — do not mix without documenting.
