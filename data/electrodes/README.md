# `data/electrodes`

Sample EEG / NIRS cap layouts as whitespace-separated `.dat` files (no header). Typical line: `x y z label` in millimetres. Parsed by `core.io.electrodes.from_dat` (3, 4, 6, or 7 columns). These files are **not** attached to a mesh until you import them and run a lead field.

**Import → Import electrodes** (`core.gui.menu_tool.import_electrodes_callback`) opens a file picker; point it here or copy a layout next to a project.

| Prefix | Caps |
|--------|------|
| `standard-1020`, `standard-1005` | 10–20 / 10–05 |
| `biosemi-*` | BioSemi 16–256 |
| `GSN-HydroCel-*`, `EGI-256` | EGI GSN HydroCel |
| `easycap-M-*` | EasyCap M-1 / M-10 |
| `brainproducts-RNP-BA-128` | BrainProducts |
| `mgh-60`, `mgh-70` | MGH |
| `artinis-brite-23`, `artinis-octamon` | Artinis NIRS |

Coordinates are **not** converted. They must already match the project length unit. Format details: [`+core/+io/+electrodes/README.md`](../../+core/+io/+electrodes/README.md).
