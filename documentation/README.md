# documentation

## Folder purpose

**Standalone technical documentation** for Zeffiro Interface, separate from per-folder `README.md` files in the codebase. Contains LaTeX sources for mesh generation, lead-field construction, and inverse methods, plus an auto-generated doc-pass manifest from maintenance scripts.

## Main contents

| Item | Role |
|------|------|
| `main.tex` | Root LaTeX document with table of contents |
| `preamble.tex` | Document class, packages, fonts |
| `mesh_generation.tex` | FEM mesh chapter |
| `lead_field_construction.tex` | Lead-field theory and implementation notes |
| `inverse_methods.tex` | Inverse solver chapter |
| `fonts/` | Font files for PDF build |
| `doc_pass_manifest.txt` | Lists directories and files touched by automated doc header pass (`scripts/zeffiro_doc_pass.py`) |

## Code functionality

This folder is **not** added to the MATLAB path at startup. `zeffiro_interface.m`, `zef_start.m`, and `zef_plugin.m` do not reference it.

Build PDFs with a local TeX distribution:
```bash
cd documentation && pdflatex main.tex
```

`doc_pass_manifest.txt` is for audit only — not consumed at runtime.

## Workflow context

Complements in-repo `README.md` trees under `src/`, `+inverse`, `tools/plugins`, etc. LaTeX chapters may lag the refactored `+inverse` class API; prefer code and package READMEs for API truth.

## Usage instructions

Researchers writing papers or theses: compile `main.tex` after updating chapter `.tex` files.

Maintainers after bulk documentation updates: inspect `doc_pass_manifest.txt` for scope of changed headers.

## Important notes

- LaTeX content is not validated by MATLAB tests.
- Per-folder READMEs (this documentation pass) are the primary developer onboarding material.
- `external/` submodule docs remain upstream (CVX, FieldTrip, etc.).

## Developer guidance

- When algorithms change materially, update the matching `.tex` chapter and cite version/date.
- Do not duplicate full API listings in LaTeX — link to `+inverse` and `src/inverse` READMEs instead.
- Regenerate `doc_pass_manifest.txt` only via `scripts/zeffiro_doc_pass.py` if using that tooling; manual README edits do not require it.
