# Find synthetic source — MATLAB files (`m/`)

These files implement the **built-in** Forward-tools item **Find synthetic source** (hardcoded in `zef_menu_tool.m`, not an INI plugin). They place dipoles on `zef.source_positions`, form `zef.measurements = L × sources + noise`, and optionally a Blackman–Harris time course.

Amplitude is **nAm**, scaled by `1e-3` in `zef_find_source`. Noise is **dB** (`10^(dB/20)`). The INI sibling **Find synthetic source legacy** is a different folder (`FindSyntheticSourceLegacy/`: linear-fraction noise). User-facing buttons and table columns: [parent README](../README.md).

## Typical scripted sequence

```matlab
zef = find_synthetic_source(zef);   % or find_synthetic_source; from the menu
zef = zef_update_fss(zef);          % table → inv_synth_source + pulse cells
[zef.time_sequence, zef.time_variable] = zef_generate_time_sequence(zef);
zef.measurements = zef_find_source(zef);
zef.h_synth_source = zef_plot_source(1);   % 1 = synthetic arrows; 2 = reconstructed
```

Needs `zef.L` and `zef.source_positions`. Each xyz is snapped to the nearest source point.

| File | Role |
|------|------|
| `find_synthetic_source` | Open App Designer window; `synth_source_init` labels |
| `add_synthetic_source` / `remove_synthetic_source` | List rows on `synth_source_data` |
| `zef_update_fss` | Pack parameters → `inv_synth_source` and pulse cells |
| `zef_find_source` | Nearest-point dipoles through `L`; dB noise; optional `time_sequence` |
| `zef_generate_time_sequence` | Blackman–Harris × cosine pulses |
| `zef_plot_source` | 3-D arrows (type 1 synth / type 2 reconstructed) |
| `zef_plot_source_intensity` | Curves vs `time_variable`, or a bar when `fss_time_val` is set |
