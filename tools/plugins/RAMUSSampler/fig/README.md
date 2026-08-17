# RAMUSSampler — GUIDE layout (`fig/`)

## Folder purpose

Stores the GUIDE window for the **Metropolized RAMUS Sampler** plugin. That plugin draws posterior samples on the same multiresolution source space used by RAMUS MAP inversion (Metropolis–Hastings over random decompositions / levels), and averages accepted draws into **`zef.reconstruction`**. It is a sampling companion to RAMUS, not the MAP RAMUS inverter and not an `inverse.*Inverter`.

## Main contents

| File | Role |
|------|------|
| `ramus_sampler.fig` | GUIDE figure opened by `ramus_sampler` |
| `README.md` | This documentation |

Sibling MATLAB: `../m/ramus_sampler.m` (open + init), `ramus_sampling_process.m` (MH loop), `zef_init_ramus_sampler.m` / `zef_update_ramus_sampler.m`.

## Code functionality

Start script opens this `.fig` (all platforms use `open('ramus_sampler.fig')`), stores the handle as `zef.h_ias_map_estimation` (historical name reuse), sets the title **ZEFFIRO Interface: Metropolized RAMUS Sampler**, then runs `zef_init_ramus_sampler`. Start Callback inside the figure:

```matlab
zef_update_ramus_sampler; zef.reconstruction = ramus_sampling_process([]);
```

Likelihood uses `zef.inv_likelihood_std` (a standard deviation), not `inv_snr`. Sampler counts: `inv_n_sampler`, `inv_n_burn_in`; multires fields: `inv_multires_*`.

## Workflow context

Parent plugin: `tools/plugins/RAMUSSampler`. **Not** listed in any profile `zeffiro_plugins.ini` — call from MATLAB. Related MAP GUI: `RAMUSInversion`. Requires `zef.L`, measurements, and a built multiresolution decomposition (`inv_multires_dec` / `_ind`) before sampling is meaningful.

## Usage instructions

```matlab
ramus_sampler;   % opens ramus_sampler.fig + zef_init_ramus_sampler
```

Ensure Create multiresolution decomposition has been run successfully first (see Important notes). Apply only runs `zef_update_ramus_sampler`; Start runs the Metropolized sampling process.

## Important notes

- Real figure file name: **`ramus_sampler.fig`**.
- Start script that opens it: **`ramus_sampler`** (`../m/ramus_sampler.m`).
- Parent plugin purpose: Metropolized RAMUS posterior sampling → averaged `zef.reconstruction`.
- Fig **Create multiresolution decomposition** currently calls `make_multires_dec` (no first-party function). Prefer `zef_make_multires_dec` or the RAMUS inversion Create button.
- Start does not assign `reconstruction_information`.
- Reads `zef` from the base workspace.

## Developer guidance

- Fix Create to call `zef_make_multires_dec` before registering this tool in any INI.
- Keep MH math in `ramus_sampling_process.m`; keep widget tags stable for init/update.
- Do not confuse this folder with EXP IAS/EM RAMUS GUIDE figures under `tools/plugins/EXP/`.
