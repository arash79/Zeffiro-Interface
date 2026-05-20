# scripts

## Purpose of this folder

Developer-facing scripts that are **not** added to the MATLAB path at Zeffiro startup. Used for contribution guidelines, data-management notes, and documentation maintenance.

## Contents

| Item | Role |
|------|------|
| `CONTRIBUTING.md` | Contribution expectations |
| `data/README.md` | Notes on script-related data assets |
| `zeffiro_doc_pass.py` | Regenerates per-file MATLAB headers and per-folder `README.md` from static code analysis |

## How this folder fits into the overall workflow

Runtime users start `zeffiro_interface.m` at the repo root. Maintainers run `zeffiro_doc_pass.py` after refactors to refresh comments and folder READMEs without changing algorithms.

## GUI usage

None.

## Programmatic usage

```bash
cd /path/to/MainZeffiroProject
python3 scripts/zeffiro_doc_pass.py          # rewrite headers + READMEs
python3 scripts/zeffiro_doc_pass.py --dry-run # analysis only
```

Manifest written to `documentation/doc_pass_manifest.txt` (folder list, updated headers).

## Examples

After moving `+core` or `src` files:

```bash
python3 scripts/zeffiro_doc_pass.py
git diff +core README.md src/forward/lead_field/*.m
```

## Dependencies and assumptions

- Python 3.8+
- Does not require MATLAB; parses `.m` files as text
- Skips `external/` and `.git/`
- Only modifies comment blocks and `README.md` files

## Notes for developers

- Hand-edit architecture READMEs at repo root and `+core`, `+inverse`, `src`, `+utilities` after major design changes—the script uses heuristics for bulk coverage.
- Do not use the script to change executable MATLAB lines; review diffs for accidental edits.
