# tools/plugins/FindSyntheticSourceLegacy

## Folder purpose

The **default-profile** synthetic-source window: a short list of dipoles (position, orientation, amplitude, noise) projected through `zef.L` onto the nearest source points. Writes a **single time sample** to `zef.measurements` (no pulse train). Noise is a linear fraction of `max(abs(meas))`, not dB.

Use this when the menu says **Find synthetic source legacy**. The multi-source / time-sequence UI is **Forward tools → Find synthetic source** (`FindSyntheticSource/`, hardcoded in `zef_menu_tool.m`, dB noise).

## Main contents

- Start: `zef_find_synthetic_source_legacy` → window helpers
- Update: `zef_update_fss_legacy`
- Solver: `zef_find_source_legacy.m` (file; function name inside is `find_source`)
- Plot: `zef_plot_source_legacy`
- App: `zef_find_synthetic_source_legacy_app.m`

## Code functionality

Need `zef.L` and `zef.source_positions`.

Buttons (`Callback` in `zef_find_synthetic_source_legacy_app.m`):

| Label | Action |
|-------|--------|
| **Plot source(s)** | `zef = zef_update_fss_legacy(zef); zef.h_synth_source = zef_plot_source_legacy(zef,1)` |
| **Create synthetic data** | `zef = zef_update_fss_legacy(zef); zef.measurements = zef_find_source_legacy(zef)` |

`zef_update_fss_legacy` packs the ten widgets into `zef.inv_synth_source` (columns: xyz, ori, amplitude, noise, visual size, color).

## Workflow context

**Forward tools → Find synthetic source legacy** (default profile). Callback: `zef_find_synthetic_source_legacy` → `zef_tool_start(..., 'zef_find_synthetic_source_legacy_window', ...)`. Title: **ZEFFIRO Interface: Find synthetic source**.

## Usage instructions

```matlab
zef = zef_update_fss_legacy(zef);
zef.measurements = zef_find_source_legacy(zef);
```

1. Ensure lead field and source positions exist.
2. Open Forward tools → Find synthetic source legacy.
3. Plot source(s) and/or Create synthetic data.

## Important notes

- Single time sample only; noise is a linear fraction of `max(abs(meas))`, not dB.
- Distinct from newer **Find synthetic source** (`FindSyntheticSource/`, dB noise, time sequences).
- File `zef_find_source_legacy.m` contains function `find_source`.

## Developer guidance

Preserve callback `zef_find_synthetic_source_legacy` and `zef.inv_synth_source` column layout. Do not confuse with `FindSyntheticSource/` menu wiring in `zef_menu_tool.m`.
