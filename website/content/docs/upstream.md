# Differences from upstream Zeffiro

This tree is derived from [zeffiro_interface](https://github.com/sampsapursiainen/zeffiro_interface). Public function names (`zef_*`, `inverse.*Inverter`, `utilities.*`) are meant to stay recognizable. Numerical output is **not** guaranteed to match `main_development_branch`.

Compatibility comparisons in this fork last used `upstream/master` at `a52ef0850cd1a1cc54826e169a05e91e9ee3a1ba` (merge of PR #273 from `main_development_branch`). The live upstream development tip at that fetch was `ad2414b693df3edc494c833485f500827276a741`.

Use this page when you are comparing reconstructions, lead fields, or saved projects against an upstream clone.

## Two inverse tracks

Inverse-tools menus without **(class solver)** still call functions under `plugins/`. Scripts, cluster jobs, and **(class solver)** menus call class solvers in `+inverse` through `zef_inverse_run`. Those tracks do not share solver code and can differ on the same data. Details: [ADR-002](adr/ADR-002-dual-inverse-tracks.md), [methods.md](methods.md).

Default profiles label class-track Inverse-tools entries **(class solver)**. Matching legacy menus, when present, remain plugin algorithms.

## Methods whose numbers differ from upstream

These are intentional. They change reconstructions or lead fields versus the upstream files of the same name.

| Area | What this tree does |
|------|---------------------|
| MEG gradiometer FEM and FI/EW | Distance law \(\|r\|^{-3}\) and the directional derivative of the magnetometer field |
| Class MNE / WMNE | Per-column Dale/Lin depth weights (not a mean of \(\theta\)) |
| HALpR / EXP \(q=2\) IRLS | Scale \(\max\|f\|_\infty^2\); a zero frame returns \(z=0\) |
| RAP-MUSIC | Oriented topographies \(a=L(r)u\) with RAP projector \(P=I-QQ'\); all `n_interp` blocked locations are searched |
| Mode-3 Dale/Lin energy | Per lead-field column, not `reshape(...,3,[])` |
| Gravity types 1–4 | Newtonian \(V/\|r\|\), \(Vr/\|r\|^3\), \(n\cdot g\), \(\partial_n g\), with millimetres converted to metres before SI \(G\) |
| FA → conductivity | Westin \(C_L\) from FA, then the uniaxial map |
| DTI Apply | Polar \(R\sigma R^\top\) after sampling; iso fallback uses active-compartment indices |
| CEM import parsers | Stored columns are `[outer inner Z]` (the order `zef_attach_sensors_volume` reads) |
| Class IAS / RAMUS | Prior stored as a standard deviation; RAMUS recomputes the hyperprior every subproblem |
| Class sLORETA 3D | Interleaved xyz triplets |
| Approx standardized Kalman RTS | Applies \(Z m\) with \(Z \approx P^{-1/2}\) from an SPD inverse square root |
| UKFNMM | Maps U-space Kalman state to physical dipoles before the neural-mass stage; UKF \(\alpha=1\), \(\beta=2\) |
| Plugin 3D sLORETA (constrained) | \(1/\sqrt{\mathrm{PL}}\) |
| Standardized Kalman RTS | RTS on the raw mean, then the filter’s stored \(D_t\) |
| Anisotropic lead-field types 6–10 | Sensor millimetre→metre scaling matches types 1–5 |
| CPU PEM infinite \(Z\) | Zeros only electrode 1 in each PCG block, not the whole first block |
| EIT Jacobian \(D_A\) | \(\int\nabla\psi_i\cdot\nabla\psi_j\) (no extra off-diagonal products) |
| NaN source columns | The whole interleaved xyz triplet is dropped |

Units, CEM column layout, and PCG behaviour: [conventions.md](conventions.md). Class formulas: [methods.md](methods.md).

## Behaviours that fail loudly instead of returning zeros

Unimplemented paths error rather than producing an empty or silently wrong `L`:

- MEG St. Venant interpolation in cartesian source space
- EEG `face_based` / default `mesh based` direction mode (errors before stiffness/PCG; upstream still runs PCG then skips interpolation)
- Buried complete-electrode-model contacts
- PEM EIT

There is still **no** buried-CEM or PEM-EIT solver.

## Project files and startup

- Loading a one-variable legacy `.mat` (`save(...,'zef')`) no longer rewrites that file.
- Save strips machine/session fields (`gpu_count`, `path_cell`, `start_mode`, `github_updater_*`).
- Startup does not run `git pull`. The name-value `use_github` is accepted and ignored so older scripts still parse.

## MATLAB

R2023a or newer. Inverse precompute paths use `pageeig` (R2023a) and `pagesvd` (R2021b).
