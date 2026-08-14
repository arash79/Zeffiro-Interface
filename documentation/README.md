# Printed Zeffiro manual (`documentation/`)

This folder is the **typeset product manual**: three LaTeX chapters that explain the scientific pipeline (mesh → lead field → inverse) using the same `zef` fields the live MATLAB code reads. It is **not** on the MATLAB path. `zeffiro_interface`, `zef_start`, and `zef_plugin` never load it.

Use it when you want a paper-style account of what a field means and which equation the solver implements. Use the **folder README tree** and MATLAB `help` when you want GUI paths, function signatures, and plugin menus.

## How this manual relates to the rest of the docs

| Layer | Where | What it is for |
|-------|--------|----------------|
| This PDF | `documentation/*.tex` | Concepts, `zef` field tables, eLORETA equations |
| Folder READMEs | repo root, `src/`, `+inverse/`, `tools/plugins/`, … | How to open a window, which callback runs, what to call from MATLAB |
| MATLAB `help` | first-party `.m` files | Arguments, defaults, side effects of one function |

The implementation in this tree is the source of truth. If a README and a `.tex` chapter disagree, trust the code and the README that was written from it. These chapters describe mesh generation (`src/mesh`), lead fields (`src/forward/lead_field`), and class inverse solvers (`+inverse`). They do **not** replace plugin manuals under `tools/plugins`.

## Chapters

1. **Mesh generation** (`mesh_generation.tex`) — closed tissue surfaces → tetrahedral FEM mesh. Mesh tool **Create FEM mesh**, `zef_create_finite_element_mesh`, lattice modes, labeling, refinement, postprocess. Field table from `zef_init` defaults and `src/mesh`.
2. **Lead field construction** (`lead_field_construction.tex`) — `zef.L` as the linear map sources → sensors. Mesh tool **Run script**, types 1–10 (isotropic and anisotropic), PCG transfer, interpolation `G`. Gravity, NSE, and DTI are mentioned only to say they are not this dispatcher.
3. **Inverse methods** (`inverse_methods.tex`) — two tracks (Inverse-tools plugins vs `zef_inverse_run` / `inverse.*Inverter`). eLORETA equations match `ELORETAInverter`. Other class solvers are summarized; plugin windows are listed in `tools/plugins/README.md`.

`main.tex` inputs those three chapters in that order. Macros `\zeffield`, `\ccode`, `\comptag` are defined in `preamble.tex`.

## Building the PDF

The preamble loads `fontspec` and `pdfx` (PDF/A). That requires **LuaLaTeX**, not pdfLaTeX:

```bash
cd documentation
lualatex main.tex
lualatex main.tex   # second pass for the table of contents
```

Fonts are the OTF/TTF files in `fonts/` (Erewhon body, JuliaMono listings). Do not rename them; `preamble.tex` hard-codes those filenames.

A full TeX distribution with `fontspec`, `pdfx`, `luatex85`, and `xparse` is required. MATLAB tests do not compile this folder.

## What is not in this PDF

- GUI menu wiring, plugin INI rows, Data Bank, Filter tool, DTI, NSE, tES workbench — `tools/plugins/` and `src/gui/`
- FreeSurfer / SimNIBS / Brainstorm / DUNEuro converters — `+utilities`
- Cluster dispatch — `+utilities/+cluster`
- Examples and tests — `+examples`, `+tests`

Start from the repository root [README.md](../README.md) for the end-to-end GUI and scripting workflow, then come back here for the mesh / lead-field / inverse mathematics.

## Files that are not documentation chapters

| File | Role |
|------|------|
| `doc_pass_manifest.txt` | Historical list from a removed bulk-header script. Ignore for new work. |
| `fonts/` | Fonts for the PDF only |

## Developer notes

When mesh, lead-field, or class-inverse behaviour changes in a way that would mislead a reader of the PDF, update the matching `.tex` chapter from the new implementation. Do not paste full MATLAB APIs into LaTeX; point to `+inverse/@*Inverter/README.md` and `src/forward/README.md` instead.
