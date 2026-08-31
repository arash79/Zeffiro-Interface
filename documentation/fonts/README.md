# documentation/fonts

## Folder purpose

Font files for the **LuaLaTeX / XeLaTeX** technical manual under `documentation/`. They are loaded via `fontspec` from `documentation/preamble.tex` (`Path = ./fonts/`). These files are **not** on the MATLAB path and are unused by the GUI.

## Main contents

### Erewhon (serif / main text) — OpenType `.otf`

| File | Role |
|------|------|
| `Erewhon-Regular.otf` | Main roman (`\setmainfont`) |
| `Erewhon-Bold.otf` | Bold |
| `Erewhon-Italic.otf` | Italic |
| `Erewhon-BoldItalic.otf` | Bold italic |

### JuliaMono (monospace / code) — TrueType `.ttf`

| File | Role |
|------|------|
| `JuliaMono-Regular.ttf` | Main mono (`\setmonofont`) |
| `JuliaMono-Bold.ttf` | Bold mono |
| `JuliaMono-MediumItalic.ttf` | ItalicFont in preamble |
| `JuliaMono-BoldItalic.ttf` | Bold italic mono |

## Code functionality

No executable code. `documentation/preamble.tex` sets `\setmainfont{Erewhon-Regular.otf}` and `\setmonofont{JuliaMono-Regular.ttf}` with `Path = ./fonts/` and matching `BoldFont` / `ItalicFont` / `BoldItalicFont` filenames. LuaLaTeX/`fontspec` reads the binaries at compile time. MATLAB `which` will not find these files unless you add this folder yourself — do not.

## Workflow context

```
documentation/preamble.tex → ./fonts/*.otf and *.ttf → lualatex main.tex → PDF
```

Unrelated to `assets/fig` (GUI icons) and to `src/gui/chrome` (runtime theme fonts, which use the system UI font at `zef.font_size`).

## Usage instructions

```bash
cd documentation
lualatex main.tex
```

Keep the working directory such that `./fonts/` resolves next to `preamble.tex`. Do not `addpath` these into MATLAB.

## Important notes

- Erewhon is OpenType; JuliaMono here is TrueType. Mixing those extensions in `preamble.tex` is intentional.
- These copies are for the manual build. They are not a general font license redistributable for the MATLAB GUI.
- Redistribution terms: [LICENSE.md](LICENSE.md) (SIL Open Font License 1.1).
- Missing files produce `fontspec` errors at TeX time, not at `zeffiro_interface` start.

## Developer guidance

When changing manual fonts, update `preamble.tex` and keep this folder’s basenames in sync with `BoldFont` / `ItalicFont` entries. Grep `documentation/` for `Erewhon` / `JuliaMono` before renaming files.
