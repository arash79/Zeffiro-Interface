# documentation/fonts

## Folder purpose

Font files for the **LuaLaTeX / XeLaTeX** technical manual under `documentation/`. They are loaded via `fontspec` from `documentation/preamble.tex` (`Path = ./fonts/`). These files are **not** on the MATLAB path, unused by the GUI, and unrelated to Zeffiro runtime theming (`zef.font_size`, UI helpers).

Ship these fonts with the documentation tree so PDF builds are reproducible without relying on system-installed typefaces.

## Main contents

### Erewhon (serif / main text) — OpenType `.otf`

| File | Role |
|------|------|
| `Erewhon-Regular.otf` | Main roman (`\setmainfont`) |
| `Erewhon-Bold.otf` | Bold |
| `Erewhon-Italic.otf` | Italic |
| `Erewhon-BoldItalic.otf` | Bold italic |
| `Erewhon-RegularSlanted.otf` | Slanted regular (available) |
| `Erewhon-BoldSlanted.otf` | Slanted bold (available) |

### JuliaMono (monospace / code) — TrueType `.ttf`

| File | Role |
|------|------|
| `JuliaMono-Regular.ttf` | Main mono (`\setmonofont`) |
| `JuliaMono-Bold.ttf` | Bold mono |
| `JuliaMono-MediumItalic.ttf` | Used as ItalicFont in preamble |
| `JuliaMono-BoldItalic.ttf` | Bold italic mono |
| `JuliaMono-Light.ttf` / `LightItalic.ttf` | Lighter weights |
| `JuliaMono-Medium.ttf` | Medium weight |
| `JuliaMono-SemiBold.ttf` / `SemiBoldItalic.ttf` | Semi-bold |
| `JuliaMono-ExtraBold.ttf` / `ExtraBoldItalic.ttf` | Extra-bold |
| `JuliaMono-Black.ttf` / `BlackItalic.ttf` | Black weight |
| `JuliaMono-RegularLatin.ttf` / `BoldLatin.ttf` | Latin subset cuts |
| `JuliaMono-RegularItalic.ttf` | Regular italic |

`README.md` — this documentation. Preamble currently selects a subset (Regular/Bold/Italic/BoldItalic mapping); other weights are available for future `\newfontfamily` uses.

## Code functionality

None in MATLAB. TeX-only:

```tex
\usepackage{fontspec}
\setmainfont[..., Path=./fonts/, Extension=.otf]{Erewhon-Regular}
\setmonofont[..., Path=./fonts/, Extension=.ttf]{JuliaMono-Regular}
```

See `documentation/preamble.tex` for the exact `BoldFont` / `ItalicFont` / `BoldItalicFont` mappings and mono `SizeFeatures`.

## Workflow context

```
documentation/main.tex
        → preamble.tex (fontspec)
        → documentation/fonts/*.{otf,ttf}
        → LuaLaTeX / XeLaTeX → PDF manual
```

| Consumer | Uses these fonts? |
|----------|-------------------|
| `documentation/` PDF build | Yes |
| `zeffiro_interface` GUI | No |
| `assets/fig` logos | No |

PDFLaTeX cannot load these OpenType/TrueType faces through `fontspec`; the manual build instructions assume LuaLaTeX or XeLaTeX.

## Usage instructions

```bash
cd documentation
# Use LuaLaTeX or XeLaTeX so fontspec can load these fonts
lualatex main.tex
# or
xelatex main.tex
```

Keep the working directory such that `./fonts/` resolves next to `preamble.tex` as written (`Path = ./fonts/`). If you move the preamble, update the `Path` option.

To try an alternate mono weight in TeX, point `BoldFont` / `ItalicFont` at another `JuliaMono-*.ttf` present in this folder and rebuild.

## Important notes

- **PDFLaTeX** will not load these fonts via `fontspec`.
- Redistribute fonts only under their respective licenses (Erewhon / JuliaMono license terms).
- Large binary weight; do not duplicate the full set into `assets/` or MATLAB resource folders.
- Changing only a font file without updating `preamble.tex` names will break the build if basenames diverge.

## Developer guidance

- When changing manual fonts, update `preamble.tex` and keep this folder’s basenames in sync with `BoldFont` / `ItalicFont` entries.
- Do not `addpath` these into MATLAB; UI fonts are a separate concern.
- If adding a third family (e.g. math), document the new files in this table and the preamble block that loads them.
- Prefer subset/Latin cuts only when full JuliaMono is too heavy for a specific CI artifact — document which cut the preamble uses.
- Grep `documentation/` for `Erewhon` / `JuliaMono` before renaming files.
