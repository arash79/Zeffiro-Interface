# tools/plugins/ReconstructionTool/m/apply_functions

## Folder purpose

Small **post-process kernels** applied to reconstructions from the Reconstruction Tool (mean / power and similar). Parent `m/` owns bank/UI wiring; this folder is the apply-function library discovered or called by name.

## Main contents

| File | Role |
|------|------|
| `zef_reconstructionTool_mean.m` | Reduce / average reconstruction frames or components |
| `zef_reconstructionTool_power.m` | Power / energy-style transform of reconstruction |

Additional apply functions may appear beside these — follow the `zef_reconstructionTool_*` naming pattern.

## Code functionality

Each function takes reconstruction data (and possibly `zef` context) and returns a transformed reconstruction suitable for plotting or further bank storage. Exact signatures are in the file headers.

## Workflow context

```
Inverse → zef.reconstruction
  → Reconstruction Tool → apply_functions
  → updated reconstruction / display
```

## Usage instructions

Prefer the Reconstruction Tool UI Apply dropdown. Programmatic:

```matlab
% See help zef_reconstructionTool_mean / _power for arguments
```

## Important notes

- Does not run inverse solvers.
- Input size must match the tool’s expected frame layout.

## Developer guidance

- Add new applies as `zef_reconstructionTool_<name>.m` and register them in the parent tool’s list builder.
- Pitfall: mutating `zef.reconstruction` in place without copying when the bank still references the old array.
