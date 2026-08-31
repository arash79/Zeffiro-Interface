# Figure-tool colormaps (`src/visualization/colormaps`)

## Folder purpose

Named **look-up table (LUT)** functions for the Figure tool **Colormap:** popup, plus a pointwise brightness/contrast reshape. Registration is by **function name** in `zef_init` (`zef.colormap_cell` / `zef.colormap_items`), **not** by scanning this directory.

Index 13 (`Parcellation`) is `zef_parcellation_colormap` in `src/parcellation`, not this folder.

## Main contents

| File | `colormap_cell` index | Popup label |
|------|----------------------|-------------|
| `zef_colormap.m` | dispatcher | Reads `zef.colormap_cell{k}(colortune_param, colormap_size)` |
| `zef_brightness_and_contrast.m` | — | `((x+b)/(1+b))^(1+c)` after the LUT; `b=c=0` is identity; **does not clip** to `[0,1]` |
| `zef_monterosso_colormap.m` | 1 | Monterosso (four-stop dark / teal / light blue / yellow) |
| `zef_intensity_1_colormap.m` … `_3_` | 2–4 | Intensity I–III |
| `zef_contrast_1_colormap.m` … `_5_` | 5–9 | Contrast I–V |
| `zef_blue_brain_1_colormap.m` … `_3_` | 10–12 | Blue brain I–III |
| `zef_easter_colormap.m` | 14 | Easter |
| `zef_greyscale_colormap.m` | 15 | Greyscale (`linspace(0.15,0.95).^param`) |

`zef_init` also lists `'zef_parcellation_colormap'` at index 13 (implemented under `src/parcellation`).

## Code functionality

Each named LUT has signature:

```text
colormap_vec = zef_<name>_colormap(colortune_param, colormap_size)
```

Output is `colormap_size × 3` RGB in `[0,1]` (Monterosso max-normalizes). `colortune_param` (Figure-tool color-tune slider, stored as `zef.colortune_param`) shifts band edges; `colormap_size` is `zef.colormap_size`.

`zef_colormap(inv_colormap)` takes a **1-based index** (`zef.update_colormap` from the popup). It `evalin`s `zef` from the **caller** workspace if present, else **base**, then `eval`s `colormap_cell{k}(...)`. It is not a pure function of the index alone.

Brightness/contrast sliders call `zef_brightness_and_contrast` on that RGB matrix. Values can leave `[0,1]`; plot code may still accept them.

## Workflow context

```
zef_init → colormap_items / colormap_cell
Figure tool Colormap: popup → zef.update_colormap (index)
  → zef_colormap(index) → named LUT in this folder
  → optional zef_brightness_and_contrast
  → src/gui/plot applies the LUT to the current overlay
```

Mesh-vis **Graph:** items are **not** here; they are dir-discovered under `graph_bank/`.

## Usage instructions

```matlab
% After a live session (zef in base or caller):
rgb = zef_colormap(1);                    % Monterosso, uses zef.colortune_param
rgb = zef_monterosso_colormap(1, 256);    % direct, no session
rgb = zef_brightness_and_contrast(rgb, 0.1, 0.2);
```

Do not `feval` a LUT without the two scalar arguments; that is the contract `colormap_cell` stores.

## Important notes

- Adding a `.m` file here does **nothing** until you append its function name to `zef_init` `colormap_cell` **and** a matching label to `colormap_items`.
- `zef_colormap` uses `eval` on the function name string. Names must be valid MATLAB identifiers already on the path.
- Parcellation LUT reads `zef.parcellation_colormap` from base and returns `[]` if the field is missing (`tests.unit.ParcellationColormapTest`).
- `ArchitectureLayoutTest` asserts `which('zef_colormap')` contains `src/visualization/colormaps`.

## Developer guidance

- Keep existing function names stable; the Figure tool stores an integer index, not a filename the user chose.
- New LUT: copy an existing `zef_*_colormap.m`, return `size×3` in `[0,1]`, register in `zef_init`, document the new index in this table.
- Do not mix graph-bank plotters or movie writers into this folder.
- Pitfall: inserting a LUT in the middle of `colormap_cell` — every saved project that stored `update_colormap` as an index will point at the wrong map.
