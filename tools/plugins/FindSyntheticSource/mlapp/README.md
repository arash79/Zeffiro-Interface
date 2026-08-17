# FindSyntheticSource — App Designer layouts

## Folder purpose

App Designer UI for **Find synthetic source**: place one or more dipoles (optional Gaussian / Blackman–Harris time course) and write `zef.measurements = L × sources + noise`.

## Main contents

| File | Role |
|------|------|
| `find_synthetic_source_app.mlapp` | Find synthetic source window (Add/Remove source, time sequence, Create synth data, plots) |
| `README.md` | This documentation |

MATLAB logic: `tools/plugins/FindSyntheticSource/m/` (`find_synthetic_source`, `add_synthetic_source`, `remove_synthetic_source`, `zef_update_fss`, `zef_find_source`, `zef_generate_time_sequence`, plot helpers).

## Code functionality

`find_synthetic_source` opens this app and wires buttons. Sources snap to nearest `zef.source_positions`; amplitude is nAm (× `1e-3` in the forward product); noise is dB. Create synth data path updates `inv_synth_source` / pulses via `zef_update_fss`, then `zef_find_source` → `zef.measurements`.

## Workflow context

Built-in **Forward tools → Find synthetic source** (hardcoded in `zef_menu_tool.m`, every profile). Callback: `find_synthetic_source`. The INI row **Find synthetic source legacy** opens `FindSyntheticSourceLegacy/` instead — different UI and noise convention.

## Usage instructions

```matlab
find_synthetic_source; zef = zef_update(zef);   % opens find_synthetic_source_app.mlapp
% or
zef = find_synthetic_source(zef);
```

Buttons: Add/Remove source; Generate time sequence; Create synth data; Plot intensity / sources. Edit UI only in App Designer.

## Important notes

- Needs `zef.L` and `zef.source_positions`.
- Not a `zeffiro_plugins.ini` row for the non-legacy tool — menu wiring is in `zef_menu_tool.m`.
- Noise is dB here; do not mix with the legacy linear-fraction tool without documenting.

## Developer guidance

- Keep menu callback `find_synthetic_source` and App Designer binder aligned.
- Document new per-source widgets in the parent plugin README.
- MATLAB file details: parent `m/README.md`.
