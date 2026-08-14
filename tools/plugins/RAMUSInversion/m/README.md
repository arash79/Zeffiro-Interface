# RAMUSInversion / m

**RAMUS** (randomized multiresolution source space) is the GUI MAP solver for Inverse tools → **RAMUS Inversion**. You coarsen the interpolated sources into several nested decompositions, run IAS-style MAP on each block, and average. The class path is `inverse.RAMUSInverter` via `zef_inverse_run(zef,'ramus')` — this folder does not construct that object.

User manual: [parent README](../README.md). **Create decomposition** must run before Start (`ramus_multires_dec` / `_ind` / `_count`).

| File | Role |
|------|------|
| `zef_ramus_inversion_tool.m` | INI callback |
| `zef_ramus_window.m` | Names the figure; live Start → `zef_ramus_iteration` |
| `zef_ramus_app.m` | GUIDE dump (script) |
| `zef_init_ramus_inversion_tool.m` / `zef_update_ramus_inversion_tool.m` | Defaults / widgets → `ramus_*` |
| `zef_ramus_iteration.m` | Nested loops: decompositions × levels; IAS MAP on `L(:,mr_dec)`; scatter with `mr_ind`; average with sparsity weights |

SNR: `zef.ramus_snr` (dB). Time/filter widgets copy onto `zef.inv_*` inside the solver.
