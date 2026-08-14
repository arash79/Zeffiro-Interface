# preconditioned_relaxation_tool

Solve the inverse normal equations with a stored multigrid / diagonal preconditioner (iterative relaxation). Use it after **Find preconditioner** has filled `zef.relax_preconditioner`. This is a linear iterative solver, not hierarchical Bayes.

There is **no** `inverse.*Inverter`. Registry id `legacy_relax` dispatches `zef_relax_iteration`.

## Menu

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **Preconditioned relaxation tool** |
| `_legacy`, `_nse`, asteroid_radar, asteroid_gravity | same |

INI callback: `zef_relax_inversion_tool` (script).

Window title: `ZEFFIRO Interface: Preconditioned Iterative Relaxation`.

## Run the solver

**Start iteration** (`zef.h_relax_start_iteration`) `ButtonPushedFcn`:

```matlab
zef_update_relax_inversion_tool; [zef.reconstruction, zef.reconstruction_information] = zef_relax_iteration([]);
```

**Find preconditioner** (`zef.h_relax_find_preconditioner`) does **not** invert:

```matlab
zef_update_relax_inversion_tool; [zef.relax_preconditioner, zef.relax_preconditioner_permutation] = zef_relax_find_preconditioner;
```

Run Find preconditioner before Start; the iteration reads those two fields.

Dropdowns (App Designer `Items` in `zef_relax.mlapp`; `ItemsData` is `1:length(Items)`):

| Widget | Value | Label | What the solver does |
|--------|-------|-------|----------------------|
| Iteration type | 1 | Landweber method | `z ← z + γ M\(L'(f − Lz))` with `γ = 10^(-relax_db/20)` |
| Iteration type | 2 | Preconditioned conjugate gradients | PCG on `L'L z = L'f` with stored `M` as left preconditioner. The CG coefficient is also named `gamma` and **overwrites** the Landweber step size for that decomposition. |
| Preconditioner | 1 | Block diagonal RAMUS | `zef_block_diagonal_preconditioner_uniform_prior` on each RAMUS coarsening |
| Preconditioner | 2 | Diagonal RAMUS | `zef_diagonal_preconditioner_uniform_prior` |
| Preconditioner | 3 | Identity | `speye(3*n_interp)` and a trivial permutation (no RAMUS coarsening) |

Stop when the relative residual drops below `10^(-(relax_snr - relax_tolerance)/20)`, or after `relax_multires_n_iter` steps. If it does not converge, the solver prints `'Error: iteration did not converge.'` (a string in the command window, not `error()`). Each frame averages the decompositions (`length(M)`) and then calls `zef_postProcessInverse` **inside** the frame loop (the reconstruction is rewritten every frame).

## Needs

- `zef.L`, interpolation, `zef.source_direction_mode`
- `zef.measurements`
- SNR: `zef.relax_snr`; stop tolerance uses `10^(-(relax_snr - relax_tolerance)/20)` and a step size `gamma = 10^(-relax_db/20)`
- Frames: `zef.relax_number_of_frames`, `relax_time_*`, `relax_sampling_frequency`, band edges
- Preconditioner: `zef.relax_preconditioner`, `zef.relax_preconditioner_permutation`, `zef.relax_iteration_type`, `zef.relax_preconditioner_type`
- Reads `zef` from the base workspace

## Writes

- `zef.reconstruction` and `zef.reconstruction_information` (tag `Relaxation`)
- Find-preconditioner writes `zef.relax_preconditioner` and `zef.relax_preconditioner_permutation` only

## Files

- Start: `m/zef_relax_inversion_tool.m` (loads `zef_relax` app)
- Solvers: `m/zef_relax_iteration.m`, `m/zef_relax_find_preconditioner.m`
- Layout: `mlapp/zef_relax.mlapp`
