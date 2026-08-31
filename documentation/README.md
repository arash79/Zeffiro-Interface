# Printed Zeffiro manual (`documentation/`)

Three LaTeX chapters on the scientific pipeline (mesh → lead field → inverse), using the same `zef` fields the live MATLAB reads. Nothing here is on the MATLAB path. `zeffiro_interface` never loads it.

If you want the same ideas without compiling: [docs/methods.md](../docs/methods.md), [docs/zef-state.md](../docs/zef-state.md), [docs/conventions.md](../docs/conventions.md). Folder READMEs and MATLAB `help` win for GUI paths, signatures, and plugin menus.

| File | What it typesets |
|------|------------------|
| `mesh_generation.tex` | Closed surfaces → tetrahedral FEM mesh; **Create FEM mesh** / `zef_create_finite_element_mesh` |
| `lead_field_construction.tex` | `zef.L`; types 1–10; PCG transfer; interpolation `G` |
| `inverse_methods.tex` | Plugin track vs `zef_inverse_run`; eLORETA equations matched to `ELORETAInverter` |
| `main.tex` / `preamble.tex` | Inputs the chapters; macros `\zeffield`, `\ccode`, `\comptag`; `fontspec` / `pdfx` |
| `fonts/` | OTF/TTF for the PDF (Erewhon, JuliaMono); [fonts/LICENSE.md](fonts/LICENSE.md) |

Gravity, NSE, and DTI appear in the lead-field chapter only to say they are **not** that dispatcher. Plugin windows, Data Bank, converters, and cluster dispatch are out of scope here.

If a `.tex` chapter disagrees with the implementation, the implementation (and the folder README next to it) is the source of truth. `location_unit` in particular must match the Mesh tool: `1` mm, `2` cm, `3` m.

Compile with **LuaLaTeX** (not pdfLaTeX):

```bash
cd documentation
lualatex main.tex
lualatex main.tex   # second pass for TOC
```

Needs a TeX tree with `fontspec`, `pdfx`, `luatex85`, and `xparse`. MATLAB tests do not compile this folder. Do not rename the font files; `preamble.tex` hard-codes those names.

When mesh, lead-field, or class-inverse behaviour changes in a way that would mislead a PDF reader, update the matching chapter from the new code. Do not paste full MATLAB APIs into LaTeX; point at `+inverse/@*Inverter/README.md` and `src/forward/README.md`.
