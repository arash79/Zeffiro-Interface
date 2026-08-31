# inverse.RAMUSInverter

RAMUS (randomized multiresolution scanning) runs IAS-style MAP on many random sparse subsets of the source space, at several resolution levels, and averages the maps. The idea is to reduce the depth bias of a single fine-grid IAS run. You must build a multiresolution decomposition first (`zef_make_multires_dec` or sensitivity).

Registry id: `ramus`. Paper: Rezaei, Koulouri & Pursiainen, *Brain Topography* 33 (2020).

## Main contents

| File | Role |
|------|------|
| `RAMUSInverter.m` | Levels, sparsity, decomposition count, hyperpriors, `multiresolution_*` properties |
| `initialize.m` | Sets `noise_cov` from SNR (identity scale) |
| `invert.m` | Nested loops over decompositions × levels; IAS-like updates on `L_sub`; weighted average |

Helper used externally: `zef_make_multires_dec` (often via a `make_multires_dec` method or sensitivity preflight).

## Code functionality

**Requirement:** nonempty `multiresolution_dec` (else error `inverse:RAMUSInverter:NoMultiresDec`).

**Typical parameters:** `number_of_multiresolution_levels=3`, `sparsity_factor=10`, `number_of_decompositions=20`, `n_map_iterations` (scalar or per-level vector), inverse-gamma / gamma hyperpriors via `zef_find_*_hyperprior`.

**Output:** reconstruction averaged across random subproblems with sparsity weights.

## Workflow context

```
zef_make_multires_dec / sensitivity preflight → zef_inverse_run(zef,'ramus')
```

GUI: **RAMUS inversion tool** → `zef_ramus_iteration` (`legacy_ramus`).

## Usage instructions

```matlab
% Ensure multiresolution_dec is populated (mesh tool / zef_make_multires_dec / sensitivity)
[zef, r] = zef_inverse_run(zef, 'ramus', 'execution', 'local');
```

## Important notes

- Last-step dSPM/sLORETA branches compare against `n_map_iterations(mr_ind)` (per resolution level).
- Cost scales with `number_of_decompositions × levels × n_map_iterations` — keep defaults modest for interactive use.
- Sensitivity package may set `ramus_decomposition` capability flags before runs.

## Developer guidance

- Do not invent a second multires builder — extend `zef_make_multires_dec`.
- Document averaging formula when changing sparsity weights.
- Add a test that fails clearly when `multiresolution_dec` is empty (already the case) and one that succeeds with a tiny synthetic dec.
