# ReconstructionTool **Apply** transforms

Each file `zef_reconstructionTool_<name>.m` is `str2func`'d by **Apply transformation** in the ReconstructionTool window. The dropdown label is the `<name>` part after `zef_reconstructionTool_`. Adding a file here adds an item; no INI edit.

The transform runs on each **checked** bank row (checkbox column 7 of `bankInfo`) and **appends** a new row. It does not overwrite the source reconstruction. Live `zef.reconstruction` is unchanged until you **Replace**.

## Shipped transforms

| File | Input | Output |
|------|-------|--------|
| `zef_reconstructionTool_mean.m` | Cell of frames, or a vector | Frame-wise mean of a cell; a vector is returned unchanged |
| `zef_reconstructionTool_power.m` | Cell of frames, or a vector | Mean of squares across frames (`mean(x.^2)`); a vector is returned unchanged |

A new transform should accept the reconstruction stored in the bank (cell or numeric) and return a reconstruction of the same kind the plotters expect (typically a cell of 3-component source vectors, or one vector). Parent: [../../README.md](../../README.md).
