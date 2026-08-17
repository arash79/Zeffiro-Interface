# +utilities/+fs2zef/+scripts

## Folder purpose

Shell-side FreeSurfer helpers invoked by `utilities.fs2zef.run`. MATLAB does not implement marching-cubes / surface extraction here; it shells out to FreeSurfer binaries via bash.

## Main contents

| File | Role |
|------|------|
| `makeParcellation.sh` | MGZ → label surfaces → ASCII `.asc` and STL meshes under an output directory |

There are **no** `.m` files in this folder.

## Code functionality

Typical invocation (from `run.m`):

```bash
bash -lc "source SetUpFreeSurfer.sh && bash makeParcellation.sh [--lut PATH] <subject_id> <mgz_file> <output_dir>"
```

Pipeline steps inside the script:

1. `mri_segstats` → label list (optional LUT via `--lut` or `$FREESURFER_HOME`).
2. Per label: `mri_mc` (with `mri_binarize` fallback) → `mris_convert`.
3. Writes `output_dir/ascii/*.asc` and `output_dir/mesh/*.stl`.
4. Also attempts inner/outer skull and skin surfaces when present under `$SUBJECTS_DIR`.

**Environment:** `SUBJECTS_DIR`, FreeSurfer on `PATH`, bash available (macOS/Linux/WSL).

## Workflow context

```
utilities.fs2zef.run
    → +scripts/makeParcellation.sh   (this folder)
    → +readers / +transforms / +generators
    → Zeffiro project / segmentation import
```

Sibling packages under `+utilities/+fs2zef` own MATLAB parsing and project generation.

## Usage instructions

Prefer the MATLAB entry point:

```matlab
utilities.fs2zef.run(...);  % orchestrates bash + MATLAB stages
```

Manual debug:

```bash
export SUBJECTS_DIR=/path/to/subjects
bash +utilities/+fs2zef/+scripts/makeParcellation.sh subj aparc+aseg.mgz /tmp/fs2zef_out
```

## Important notes

- Not a MATLAB package function — line endings and execute bits matter on Windows/WSL.
- Some hard-coded skull/skin surface paths look missing a `/surf/` segment; those optional conversions often warn and continue.
- Label sanitization via `tr` may look surprising (`slicer` character class) — verify output names if labels look wrong.
- Failures frequently warn rather than hard-exit; always inspect the output directory.

## Developer guidance

- Change FreeSurfer CLI flags here; keep MATLAB orchestration in `run.m`.
- When fixing skull/skin paths, add a dry-run log and a small fixture test if possible.
- Do not rewrite this as pure MATLAB without an explicit FreeSurfer-free design — the tool depends on FS binaries.
