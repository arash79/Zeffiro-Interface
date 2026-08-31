# plugins/ReconstructionTool/m/apply_functions

## Folder purpose

**Post-process kernels** applied to banked reconstructions from Reconstruction Tool’s **Apply transformation** dropdown. The parent `m/` folder owns the bank UI; this directory is discovered by filename. Inverse solvers are not run here.

## Main contents

| File | Role |
|------|------|
| `zef_reconstructionTool_mean.m` | `{mean}` of cell frames along `size(reconstruction,2)` |
| `zef_reconstructionTool_power.m` | Power / energy-style transform (same cell layout) |

Dropdown labels are the suffix after `zef_reconstructionTool_` (shipped: **mean**, **power**). Extra files named `zef_reconstructionTool_<name>.m` appear automatically.

## Code functionality

`zef_reconstructionTool_apply` does `str2func('zef_reconstructionTool_' + dropdown)` on each **checked** bank reconstruction and **appends** a new bank row (does not overwrite the source).

`zef_reconstructionTool_mean`:

1. Starts from `reconstruction{:,1}`.
2. Adds `reconstruction{:,frame}` for `frame = 2:size(reconstruction,2)`.
3. Divides by `size(reconstruction,2)` and wraps `{newRec}`.

Typical inverse output is an **N×1** cell (one column). Then `size(...,2)` is 1, the loop never runs extra frames, and the result is the **first frame only**. A **1×N** cell would average across frames. Power uses the same dimension convention.

**Inputs:** cell reconstruction (not `zef`). **Outputs:** new cell. Does not write `zef`.

## Workflow context

```
Inverse → zef.reconstruction (usually N×1 cell)
  → Reconstruction Tool Add
  → Apply transformation (this folder)
  → new bank row → Replace onto live zef if desired
```

Parent: [`../README.md`](../README.md). Plugin: [`../../README.md`](../../README.md).

## Usage instructions

Prefer the tool UI. Programmatic:

```matlab
newRec = zef_reconstructionTool_mean(zef.reconstruction);
% help zef_reconstructionTool_power
```

## Important notes

- Does not invert `L`.
- N×1 vs 1×N cell orientation changes whether mean/power see multiple frames.
- Apply appends; it does not mutate the selected bank row in place.

## Developer guidance

- New applies: `zef_reconstructionTool_<name>.m` with the same cell-in / cell-out contract; document orientation in the file header.
- Pitfall: averaging “all time” on a default N×1 bank and wondering why only frame 1 changed.
