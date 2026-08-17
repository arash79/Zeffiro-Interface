# FindSyntheticSource / m

## Folder purpose

MATLAB implementation of the built-in Forward-tools item **Find synthetic source**: place dipoles on `zef.source_positions`, form `zef.measurements = L × sources + noise`, and optionally build a Blackman–Harris time course.

## Main contents

| File | Role |
|------|------|
| `find_synthetic_source` | Open App Designer window; `synth_source_init` labels |
| `add_synthetic_source` / `remove_synthetic_source` | List rows on `synth_source_data` |
| `zef_update_fss` | Pack parameters → `inv_synth_source` and pulse cells |
| `zef_find_source` | Nearest-point dipoles through `L`; dB noise; optional `time_sequence` |
| `zef_generate_time_sequence` | Blackman–Harris × cosine pulses |
| `zef_plot_source` | 3-D arrows (type 1 synth / type 2 reconstructed) |
| `zef_plot_source_intensity` | Curves vs `time_variable`, or a bar when `fss_time_val` is set |

## Code functionality

- Amplitude is **nAm**, scaled by `1e-3` in `zef_find_source`. Noise is **dB** (`10^(dB/20)`).
- Each xyz is snapped to the nearest source point.
- Update → generate time sequence → find source is the usual scripted chain.

## Workflow context

Hardcoded in `zef_menu_tool.m` (not an INI plugin). INI sibling **Find synthetic source legacy** is `FindSyntheticSourceLegacy/` (linear-fraction noise). User-facing buttons: parent [`../README.md`](../README.md).

## Usage instructions

```matlab
zef = find_synthetic_source(zef);   % or find_synthetic_source; from the menu
zef = zef_update_fss(zef);
[zef.time_sequence, zef.time_variable] = zef_generate_time_sequence(zef);
zef.measurements = zef_find_source(zef);
zef.h_synth_source = zef_plot_source(1);   % 1 = synthetic; 2 = reconstructed
```

Needs `zef.L` and `zef.source_positions`.

## Important notes

- Do not confuse with legacy linear-fraction noise or the extended source patch tool.
- Plot type argument on `zef_plot_source` selects synthetic vs reconstructed arrows.

## Developer guidance

Keep pulse-cell packing in `zef_update_fss` aligned with `zef_generate_time_sequence` and `zef_find_source`. When changing noise units, update the parent README and legacy comparison notes.
