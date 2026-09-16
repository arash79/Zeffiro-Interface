# `external/fieldtrip`

## Folder purpose

Optional **FieldTrip** toolbox (git submodule) for MEG/EEG I/O and related helpers. Zeffiro’s own electrode parsers are `core.io.electrodes`. DUNEuro MATLAB projects are imported with `utilities.duneuro2zef` (Open project or `import_duneuro_project`); FieldTrip is not required. Empty until `zeffiro_setup` populates it.

## Main contents

| Item | Role |
|------|------|
| Vendor tree (after clone) | FieldTrip release sources |
| `ft_defaults.m` | `.gitmodules` `startupscript` |

`.gitmodules`: `https://github.com/fieldtrip/fieldtrip.git`, branch `release`.

## Code functionality

On successful clone, `zef_start_config` contains:

```matlab
if isequal(zef.zeffiro_restart, 0), addpath('external/fieldtrip'); end;
run ( 'external/fieldtrip/ft_defaults.m' );
```

`ft_defaults` sets FieldTrip’s own path. That is **not** `genpath` of the whole Zeffiro `external/` tree.

## Workflow context

```
zeffiro_setup → addpath + ft_defaults
  → optional FieldTrip readers in user scripts / duneuro exports
  → Zeffiro session still uses zef.L / zef.sensors after conversion
```

Duneuro import: [`../../+utilities/+duneuro2zef/README.md`](../../+utilities/+duneuro2zef/README.md). Electrode `.dat`: [`../../+core/+io/+electrodes/README.md`](../../+core/+io/+electrodes/README.md).

## Usage instructions

```matlab
zeffiro_setup("submodules", "fieldtrip");
```

After `zeffiro_interface`, `which ft_defaults` should resolve under `external/fieldtrip` if clone succeeded.

## Important notes

- Empty until clone.
- FieldTrip on the path can shadow similarly named utilities — keep `addpath` to this folder as written by `zeffiro_setup`, not a manual `genpath(external)`.
- Vendor documentation and license remain FieldTrip’s.

## Developer guidance

- Prefer `utilities.duneuro2zef` / `core.io.electrodes` for supported Zeffiro I/O; call FieldTrip only when the user already has FT data.
- Pitfall: running `ft_defaults` twice from mixed path setups (FieldTrip also on MATLAB’s userpath).
