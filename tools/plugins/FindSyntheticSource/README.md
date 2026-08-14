# Find synthetic source (non-legacy)

Places one or more dipoles, optionally with a Gaussian-envelope time course, and writes **`zef.measurements` = L × sources + noise**.

This tool is **not** a `zeffiro_plugins.ini` row. It is wired in `zef_menu_tool.m` as a built-in Forward-tools item. The INI row **Find synthetic source legacy** opens `FindSyntheticSourceLegacy/` instead (linear-fraction noise, different window).

Needs `zef.L` and `zef.source_positions`. Each source is snapped to the nearest source point. Amplitude is nAm, scaled by `1e-3` in the forward product. Dipole noise and optional background noise are in dB (`10^(dB/20)`).

## How to open it

**Forward tools → Find synthetic source** (every profile; hardcoded menu). Callback:

```matlab
find_synthetic_source; zef = zef_update(zef);
```

Or from MATLAB:

```matlab
zef = find_synthetic_source(zef);
```

Window comes from `mlapp/` via `find_synthetic_source_app`. Title is set by that app.

## Buttons (`ButtonPushedFcn` in `m/find_synthetic_source.m`)

| Handle | Action |
|--------|--------|
| Add / Remove source | `add_synthetic_source` / `remove_synthetic_source` — `zef.synth_source_data` |
| Generate time sequence | `zef_update_fss`; `[zef.time_sequence, zef.time_variable] = zef_generate_time_sequence` |
| Create synth data | `zef_update_fss`; `zef.measurements = zef_find_source` |
| Plot intensity / time sequence | `zef_plot_source_intensity` |
| Plot sources | `zef.h_synth_source = zef_plot_source(1)` |

Parameters per source (table): xyz position, xyz orientation, amplitude (nAm), noise STD (dB), sampling frequency, peak times, pulse amplitudes/length, oscillation frequency/phase, visual length/color. Shared: `zef.fss_bg_noise`, `zef.fss_time_val`.

## Scripting

```matlab
zef = zef_update_fss(zef);
[zef.time_sequence, zef.time_variable] = zef_generate_time_sequence(zef);
zef.measurements = zef_find_source(zef);
```

The plugin-INI sibling **Forward tools → Find synthetic source legacy** is `FindSyntheticSourceLegacy/` (linear-fraction noise). **Synthetic extended source patch** is `FindSyntheticSourceLegacy_Patch/`.
