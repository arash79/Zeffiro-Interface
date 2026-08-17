## Folder purpose

GUI MAP solver for Inverse tools → **RAMUS Inversion**: randomized multiresolution source space, IAS-style MAP per block, then average. Class path is `inverse.RAMUSInverter` via `zef_inverse_run(zef,'ramus')` — this folder does not construct that object.

## Main contents

| File | Role |
|------|------|
| `zef_ramus_inversion_tool.m` | INI callback |
| `zef_ramus_window.m` | Names the figure; live Start → `zef_ramus_iteration` |
| `zef_ramus_app.m` | GUIDE dump (script) |
| `zef_init_ramus_inversion_tool.m` / `zef_update_ramus_inversion_tool.m` | Defaults / widgets → `ramus_*` |
| `zef_ramus_iteration.m` | Nested loops: decompositions × levels; IAS MAP; scatter; average |

## Code functionality

**Create decomposition** must run before Start (`ramus_multires_dec` / `_ind` / `_count`). Iteration runs IAS MAP on `L(:,mr_dec)`, scatters with `mr_ind`, averages with sparsity weights. SNR: `zef.ramus_snr` (dB). Time/filter widgets copy onto `zef.inv_*` inside the solver. Writes `zef.reconstruction`.

## Workflow context

Inverse tools → RAMUS Inversion. Parent README is the user manual. Metropolized sampler sibling: `tools/plugins/RAMUSSampler` (not in default INI). Class equivalent: `zef_inverse_run(zef,'ramus')`.

## Usage instructions

Open from the menu → **Create multiresolution decomposition** → **Start**. Or:

```matlab
zef = zef_ramus_inversion_tool(zef);
zef = zef_ramus_iteration(zef);
```

## Important notes

- Without a prior Create decomposition, Start has no valid `mr_dec` / `mr_ind`.
- GUI path does not construct `inverse.RAMUSInverter`.
- Related MCMC tool is RAMUSSampler, not this folder.

## Developer guidance

Prefer new multires math in `+inverse/@RAMUSInverter` when possible; keep this plugin as GUI + legacy iteration. Share hyperprior helpers with IAS. Document `ramus_*` field contracts in the parent README.
