# Printed Zeffiro manual (`documentation/`)

## Folder purpose

**Typeset product manual**: three LaTeX chapters that explain the scientific pipeline (mesh → lead field → inverse) using the same `zef` fields the live MATLAB code reads. It is **not** on the MATLAB path. `zeffiro_interface`, `zef_start`, and `zef_plugin` never load it. Use for a paper-style account of fields and equations; use folder READMEs and MATLAB `help` for GUI paths, signatures, and plugin menus.

## Main contents

| Item | Role |
|------|------|
| `mesh_generation.tex` | Closed surfaces → tetrahedral FEM mesh; Mesh tool **Create FEM mesh**, `zef_create_finite_element_mesh` |
| `lead_field_construction.tex` | `zef.L` sources → sensors; types 1–10; PCG transfer; interpolation `G` |
| `inverse_methods.tex` | Plugin track vs `zef_inverse_run` / `inverse.*Inverter`; eLORETA equations match `ELORETAInverter` |
| `main.tex` / `preamble.tex` | Inputs chapters; macros `\zeffield`, `\ccode`, `\comptag`; `fontspec` / `pdfx` |
| `fonts/` | OTF/TTF for the PDF (Erewhon, JuliaMono) |
| `doc_pass_manifest.txt` | Historical list from a removed bulk-header script—ignore for new work |

## Code functionality

Chapters describe mesh generation (`src/mesh`), lead fields (`src/forward/lead_field`), and class inverse solvers (`+inverse`). They do not replace plugin manuals under `tools/plugins`. Gravity, NSE, and DTI appear in the lead-field chapter only to say they are not that dispatcher.

Doc layers: this PDF (concepts / equations); folder READMEs (how to open a window / which callback); MATLAB `help` (one function’s arguments and side effects). Implementation and implementation-derived READMEs are the source of truth if they disagree with a `.tex` chapter.

## Workflow context

Not part of runtime. Not covered here: GUI menu wiring, plugin INI rows, Data Bank, Filter tool, DTI, NSE, tES workbench (`tools/plugins/`, `src/gui/`); converters (`+utilities`); cluster dispatch (`+utilities/+cluster`); examples and tests (`+examples`, `+tests`). Start from the repository root README for end-to-end GUI and scripting, then return here for mesh / lead-field / inverse mathematics.

## Usage instructions

Requires **LuaLaTeX** (not pdfLaTeX) because of `fontspec` and `pdfx` (PDF/A):

```bash
cd documentation
lualatex main.tex
lualatex main.tex   # second pass for TOC
```

Needs a full TeX distribution with `fontspec`, `pdfx`, `luatex85`, and `xparse`. MATLAB tests do not compile this folder.

## Important notes

Do not rename fonts; `preamble.tex` hard-codes those filenames. These chapters do not document every plugin window—see `tools/plugins/README.md`.

## Developer guidance

When mesh, lead-field, or class-inverse behaviour changes in a way that would mislead a PDF reader, update the matching `.tex` chapter from the new implementation. Do not paste full MATLAB APIs into LaTeX; point to `+inverse/@*Inverter/README.md` and `src/forward/README.md` instead.
