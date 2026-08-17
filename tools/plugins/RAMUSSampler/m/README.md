# tools/plugins/RAMUSSampler/m

## Folder purpose

Legacy GUIDE **Metropolized RAMUS Sampler**: posterior sampling on a multiresolution RAMUS hierarchy. **Not** listed in default `zeffiro_plugins.ini` — launch `ramus_sampler` manually. Not an `inverse.*Inverter`.

## Main contents

| File | Role |
|------|------|
| `ramus_sampler.m` | Start script: open `ramus_sampler.fig`, title “Metropolized RAMUS Sampler” |
| `zef_init_ramus_sampler.m` | Defaults for `inv_multires_*` / sampler fields onto widgets |
| `zef_update_ramus_sampler.m` | Widgets → `zef` (Start callback also runs this) |
| `ramus_sampling_process.m` | Metropolized sampler → returns `z` (assigned to `zef.reconstruction`) |

Fig: `../fig/ramus_sampler.fig`.

## Code functionality

1. Open fig → init (default `n_decompositions=20`, empty decompositions until built).
2. Start: `zef_update_ramus_sampler` then `zef.reconstruction = ramus_sampling_process([])`.
3. Sampler reads base `zef`: `L`, measurements, frames, **`inv_likelihood_std`** (not `inv_snr`), `inv_n_sampler`, `inv_n_burn_in`, `inv_multires_*`.
4. Returns samples/`z` only — **no** `reconstruction_information` struct from the process function.

Known quirk: missing `inv_n_sampler` / `inv_n_burn_in` in init may write `inv_multires_n_sampler` instead — verify fields before long runs.

## Workflow context

Related: `RAMUSInversion` plugin, `inverse.RAMUSInverter`, `zef_make_multires_dec`. Manual / research use when INI does not register the tool.

## Usage instructions

```matlab
% Session with zef.L + measurements + likelihood std:
ramus_sampler;   % Start in UI after setting multires / sampler counts
```

## Important notes

- Not on default Inverse-tools menus.
- GUIDE + `evalin('base')`.
- Build multires decompositions before expecting hierarchical sampling to work.

## Developer guidance

- Align with `inverse.RAMUSInverter` if promoting to a supported path; add INI entry + tests.
- Pitfall: assuming `inv_snr` drives the likelihood — this tool uses `inv_likelihood_std`.
