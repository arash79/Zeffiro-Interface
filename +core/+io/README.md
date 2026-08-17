# +core/+io

## Folder purpose

Session-free I/O helpers under the `core.io` package. These functions take file paths and return arrays; they do **not** read or write the live `zef` session. Project `.mat`, STL, and `.zef` persistence remain in `src/io`.

## Main contents

| Path | Role |
|------|------|
| `+electrodes/` | Electrode layout parsers (`from_dat`, `from_csv`) |
| `+electrodes/README.md` | Format details and column rules |

No other `core.io` subpackages exist yet (no generic CSV/MAT helpers here).

## Code functionality

Electrodes package (see child README for full rules):

- `core.io.electrodes.from_dat(path)` — whitespace-separated lines with 3/4/6/7 fields.
- `core.io.electrodes.from_csv(path)` — headered CSV; required `x,y,z`; optional `label` and CEM radii/impedance.

**Outputs:** `[electrode_data, electrode_labels]` where data is `N×3` or `N×6`.  
**Callers:** `core.gui.menu_tool.import_electrodes_callback`; any script may call parsers directly.

## Workflow context

```
data/electrodes/*.dat
        ↓
core.io.electrodes.from_*
        ↓
core.gui.menu_tool.import_electrodes_callback  →  zef.sensors / *_points
        ↓
mesh attach / forward (src/mesh, src/forward)  →  zef.L
```

Contrast with `src/io` (projects, logs, nodisplay save) and converter packages under `+utilities` (FreeSurfer, Brainstorm, DUNEuro).

## Usage instructions

```matlab
[data, labels] = core.io.electrodes.from_dat( ...
    fullfile(zef.program_path, 'data', 'electrodes', 'biosemi-64.dat'));
[data, labels] = core.io.electrodes.from_csv('/path/to/cap.csv');
```

## Important notes

- CSV vs DAT impedance validation differs (CSV may allow `0`; DAT requires `> 0` for CEM lines).
- No unit conversion inside parsers.
- CEM column order in files is `[inner, outer, impedance]`; later attachment code may reorder.

## Developer guidance

- Add new sensor formats as sibling functions under `+electrodes`, not ad-hoc GUI parsers.
- Keep this package free of `uigetfile` / `zef` mutation — orchestration belongs in `core.gui`.
- Add tests under `+tests` when changing column semantics.
