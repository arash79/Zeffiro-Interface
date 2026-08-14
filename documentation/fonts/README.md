# Fonts for the printed manual

OTF/TTF files referenced by `documentation/preamble.tex`. They are **not** on the MATLAB path.

Build the PDF with **LuaLaTeX** (`lualatex main.tex` from `documentation/`). pdfLaTeX cannot load `fontspec`.

- **Erewhon** — body text (`Erewhon-Regular.otf` plus Italic, Bold, BoldItalic, Slanted, BoldSlanted)
- **JuliaMono** — `listings` / code (`JuliaMono-Regular.ttf` plus Bold, italic variants, extra weights, Latin subsets)

Do not rename files; the preamble sets `Path = ./fonts/` and those exact names.
