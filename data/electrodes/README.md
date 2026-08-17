# data/electrodes

## Folder purpose

Canonical **electrode / optode layout tables** shipped with Zeffiro. Files are plain-text `.dat` layouts (mm coordinates + optional labels / CEM parameters) consumed by `core.io.electrodes.from_dat` and the Import electrodes menu.

## Main contents

Representative sets (not exhaustive):

| Pattern | Systems |
|---------|---------|
| `standard-1020.dat`, `standard-1005.dat` | 10–20 / 10–05 style |
| `biosemi-16.dat` … `biosemi-256.dat` | BioSemi caps |
| `GSN-HydroCel-*.dat`, `EGI-256.dat` | EGI / HydroCel |
| `easycap-M-1.dat`, `easycap-M-10.dat` | EasyCap |
| `brainproducts-RNP-BA-128.dat` | Brain Products |
| `mgh-60.dat`, `mgh-70.dat` | MGH layouts |
| `artinis-brite-23.dat`, `artinis-octamon.dat` | fNIRS / Artinis |

See `+core/+io/+electrodes/README.md` for field-count rules (3/4/6/7 columns).

## Code functionality

No code — data only. Parsers live in `core.io.electrodes`; GUI entry in `core.gui.menu_tool.import_electrodes_callback`.

## Workflow context

Import → `zef.sensors` / sensor point tables → mesh electrode attachment → lead-field types 1 (EEG) / related modalities. Does not by itself create `zef.L`.

## Usage instructions

GUI: **Import → electrodes**, then choose a file from this folder.

```matlab
p = fullfile(zef.program_path, 'data', 'electrodes', 'biosemi-64.dat');
[xyz, labels] = core.io.electrodes.from_dat(p);
```

## Important notes

- Coordinates are typically **millimeters** in the same frame as the head model.
- Some filenames include trailing hyphens (`GSN-HydroCel-64-.dat`) — use the exact name.
- CEM / impedance columns are optional; presence changes column count semantics.

## Developer guidance

- Add new caps as `.dat` following an existing neighbor file’s column style; include a one-line comment header only if the parser allows it (prefer no headers for `.dat`).
- Prefer CSV + `from_csv` for labeled research caps with CEM metadata.
- Pitfall: mixing a 10–20 layout with a non-MNI / non-project-scaled mesh and assuming automatic registration.
