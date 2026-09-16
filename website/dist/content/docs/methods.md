# Forward and inverse methods

This is a conceptual map of what Zeffiro computes, written so someone new to EEG/MEG inverse problems can follow it, without dropping the mathematics the solvers actually use.

Implementation details and APIs live in folder READMEs. Equations here are checked against the class solvers in `+inverse` and the FEM dispatcher `zef_lead_field_matrix`.

## The physical problem

Neural current (or another distributed source) inside a volume conductor produces electric potential and magnetic field at sensors. If we discretize candidate sources as a long vector \(x\) and stack sensor readings as \(y\), the **forward** map is linear:

\[
y \approx L x
\]

- \(y\) — measurements, length \(n_e\) (sensors) per time sample. In Zeffiro this is a column of `zef.measurements`.
- \(x\) — source degrees of freedom, length \(n_s\). Often three components per location.
- \(L\) — the **lead field**, size \(n_e \times n_s\), stored as `zef.L`. Column \(j\) is the sensor pattern produced by source component \(j\).

Building \(L\) is expensive (FEM). Inverting for \(x\) given \(y\) and \(L\) is a different, cheaper (per frame) linear algebra problem — but it is **ill-posed**: \(n_s \gg n_e\), so many \(x\) fit the data. Every inverse method in this repository is a rule for choosing one \(x\).

## How \(L\) is built

1. Closed tissue surfaces → labeled tetrahedra (`src/mesh`).
2. Conductivity \(\sigma\) on each tet (`zef.sigma`, S/m).
3. Sensors attached (PEM or CEM). Session `zef.sensors` is `N×3` or `N×6`; EEG/EIT/TES FEM then sees snapped xyz in metres (PEM) or a 4-column attachment index table (CEM). See [conventions.md](conventions.md).
4. Sparse stiffness \(A\) from P1 FEM (`zef_stiffness_matrix`).
5. Electrode coupling (`zef_build_electrodes`) and a PCG **transfer** solve for nodal potentials. EEG/TES call `zef_transfer_matrix`. MEG and EIT run the same Jacobi (GPU) or SSOR/`ichol`-nofill (CPU) loops inside their FEM files. `zef.preconditioner` is ignored on GPU.
6. Interpolation \(G\) from the FEM potential onto Whitney / H(div) / St. Venant source functions, then \(L\) from that interpolation (EEG Schur, TES current density, MEG Biot–Savart, EIT conductivity Jacobian).

Modality integers 1–10 and gravity/NSE/wave side paths: [`src/forward/README.md`](../src/forward/README.md). Length units: [conventions.md](conventions.md).

CEM electrode coupling follows the complete electrode model as used in the FEM cores; the implementation comments point at the standard volume-conductor treatment (e.g. [Phys. Med. Biol. 57 999](https://iopscience.iop.org/article/10.1088/0031-9155/57/4/999)).

## Why regularization

Unregularized least squares \(\min_x \|L x - y\|^2\) is unstable: tiny noise in \(y\) becomes huge oscillating \(x\). Methods add a penalty or a prior. A common linear form (Tikhonov / Gaussian prior) is

\[
\hat{x} = (L^\top L + \lambda I)^{-1} L^\top y
\]

or, when there are fewer sensors than sources, the equivalent **sensor-space** form

\[
\hat{x} = L^\top (L L^\top + \lambda I)^{-1} y
\]

which avoids forming the huge \(n_s \times n_s\) system. Zeffiro’s MNE, dSPM, sLORETA, and eLORETA all live in this family, with different choices of weights and of \(\lambda\) (often derived from SNR in dB).

\(\lambda\) large → smoother, weaker sources. \(\lambda\) small → noisier maps that try to fit every sensor wiggle.

## Two execution tracks

Both tracks read `zef.L` and measurements and write `zef.reconstruction`. They do **not** share solver code.

| Track | How you run it | Code |
|-------|----------------|------|
| GUI Inverse tools | Menu → plugin Start | `plugins/*` iterations (`zef_KF`, `zef_ias_iteration`, …) |
| Class / cluster | `zef_inverse_run(zef, id, …)` | `inverse.*Inverter` via `utilities.cluster.dispatch_inverse` |

Inverse-tools entries labelled **(class solver)** construct class inverters. Their Start button calls `zef_inverse_run` via `zef_open_class_inverse`. Every other Inverse-tools item still runs a legacy `plugins/*` iteration. Kalman DTI structural process-noise \(Q\) exists only on `plugins/Kalman`. See [ADR-002](adr/ADR-002-dual-inverse-tracks.md).

Registry ids (case-insensitive) are listed in `utilities.cluster.inverse_method_registry`. Ids such as `"sloreta"` select **class** `CSMInverter` but do **not** by themselves set `method_type` to sLORETA — pass `MethodParams`.

**GUI / legacy-only methods** (Inverse-tools plugins, no `@*Inverter`). You can still dispatch them from `zef_inverse_run` with a `legacy_*` id, which `feval`s the plugin function with `zef` in the base workspace:

| Registry id | Plugin | Typical use |
|-------------|--------|-------------|
| `legacy_music` | MUSIC | Subspace correlation map (SVD of a rank-1 window-mean covariance; see plugin README) |
| `legacy_rap_music` | RAP-MUSIC | Recursively peeled MUSIC with RAP projector \(P=I-QQ'\), oriented \(a=L(r)u\); Inverse tools → **RAP-MUSIC** (`RAPMUSIC_start`) |
| `legacy_sesame` | SESAME | Sequential Monte Carlo dipole sampling (Inverse tools on every shipped profile; optional `external/SESAME`) |
| `legacy_sl1` | Standardized L1 MAP | Hierarchical \(\ell_1\) via `quadprog` |
| `legacy_relax` | Preconditioned relaxation | Block-preconditioned MAP iteration |
| `legacy_exp` | EXP Lasso | EXP `exp_iteration` (also used as optimizer by class GroupLasso / HALpR) |
| `legacy_hb` / `legacy_mcmc` | Hierarchical Bayesian Sampler | MCMC sampler (`zef_mcmc`) |
| `legacy_kalman` | `zef_KF` | GUI Kalman including DTI structural \(Q\) |

`utilities.sensitivity.method_capability` marks every `legacy_*` id **unsupported**. For Monte Carlo studies use the class ids in the next section. Plugin manuals: [`plugins/README.md`](../plugins/README.md).

## Class solvers (programmatic)

### Weighted MNE (`mne`, `wmne` → `inverse.MNEInverter`)

Minimum-norm with a column weight \(\theta\):

\[
z = (\theta \odot L)^\top \bigl((\theta \odot L)\,L^\top + C\bigr)^{-1} f
\]

or \(z = W f\) when `precompute` has cached \(W\). There is no unweighted switch; \(\theta\) is always applied. \(C\) is a noise covariance (sample or SNR-scaled identity).

Use when you want a fast linear filter and a distributed estimate. GUI **Minimum norm estimation** still calls `zef_find_mne_reconstruction`.

### Cortical mapping: dSPM / sLORETA / SBL (`csm`, `dspm`, `sloreta`, … → `CSMInverter`)

Minimum-norm backbone \(P = L^\top (L L^\top + S)^{-1}\), then per-source scaling \(z = d \odot P f\).

- **dSPM** — noise-normalize using the diagonal of the resolution / noise operator (Dale et al. style).
- **sLORETA** — extra standardization so a single true dipole maps to a peak at the correct location under the method’s assumptions (Pascual-Marqui).
- **SBL** — iterative sparse Bayesian learning (gamma updates), not a single linear filter.

Default `method_type` is `"dSPM"`.

### eLORETA (`eloreta` → `ELORETAInverter`)

Iteratively reweighted minimum-norm. With weights \(W^{-1}\) and regularization \(\alpha\),

\[
T = W^{-1} L^\top (L W^{-1} L^\top + \alpha H)^{-1},\qquad z = T f.
\]

\(H = I - \frac{1}{n_e}\mathbf{1}\mathbf{1}^\top\) if average reference is on, else \(H = I\). Each free-orientation block of \(W^{-1}\) is the inverse square root of \(L_i^\top M^{-1} L_i\). If \(\alpha\) is empty at `initialize`,

\[
\alpha = \frac{\mathrm{tr}(L L^\top)}{n_e \cdot 10^{\mathrm{SNR}/10}}.
\]

`precompute` caches \(T\); `invert` is a matrix–vector product. `initialize` may fill `noise_cov`, but the class operator does **not** whiten \(L\) or \(f\) by that matrix (same as the upstream class file).

References implemented against: Pascual-Marqui (2007), arXiv:0710.3341; Pascual-Marqui (2011), *Phil. Trans. R. Soc. A* 369:3768–3784.

### IAS and RAMUS (`ias`, `ramus`)

Hierarchical Bayesian MAP: sources are conditionally Gaussian; variances have gamma or inverse-gamma hyperpriors; IAS alternates between updating \(x\) and the hyperparameters. RAMUS repeats IAS on random sparse subsets at several resolutions and averages (Rezaei, Koulouri & Pursiainen, *Brain Topography* 33 (2020), [10.1007/s10548-020-00755-8](https://doi.org/10.1007/s10548-020-00755-8)).

IAS hyperprior helpers: Calvetti & Somersalo, [10.1137/080723995](https://doi.org/10.1137/080723995).

RAMUS needs `multiresolution_dec` from `zef_make_multires_dec` (or sensitivity). Optional last-step dSPM/sLORETA scaling uses `n_map_iterations`.

### Kalman (`kalman`, `kf` → `KalmanInverter`)

State \(x_t = A x_{t-1} + w\), \(w \sim \mathcal{N}(0,Q)\), observation \(y_t \approx L x_t\). Predict/update kernels: `inverse.kf`. The identity shortcut for \(A\) is `isdiag(A)` and every diagonal entry equal to 1 (the historical `all(diag(A)-1)<eps` test was not that). Optional RTS smoother after the frame loop uses the same \(A\).

Process-noise recipes (`evolution_prior_model`) scale \(Q\) from sensitivity or SVD of \(L\). Standardized types return \(z = D x\) with an sLORETA-style \(D\).

GUI Kalman (`zef_KF`) has more filter types (block, EnKF variants) and DTI structural \(Q\). Do not assume numerical equality.

Related paper for standardized Kalman in this lineage: Lahtinen et al., *Clin. Neurophysiol.* 168 (2024), [10.1016/j.clinph.2024.09.021](https://doi.org/10.1016/j.clinph.2024.09.021).

### UKFNMM (`ukfnmm`)

Spatial Kalman on a **per-source SVD-modified** observation matrix (ordinary `kf_update`, not `kf_sL_update`), then Jansen–Rit neural mass model with UKF parameter estimation. Inverse tools → **UKF-NMM (class solver)** on every shipped profile, including the asteroid ones. See [`+inverse/@UKFNMMInverter/README.md`](../+inverse/@UKFNMMInverter/README.md) for the documented SKF-name vs `kf_update` discrepancy.

### Beamformer (`beamformer`)

Per-source spatial filters (LCMV / UNG / unit-gain) on a whitened lead field. `precompute` builds a linear operator \(B\) so each frame is \(z = B f\).

### Dipole scan (`dipolescan`)

Per-location dipole fit; reconstruction holds **goodness-of-fit**, not amplitude.

### Group LASSO / HALpR (`grouplasso`, `halpr`)

Hierarchical \(\ell_1/\ell_2\) MAP using the inner loops `LG_optimization` and `L1_optimization` in `src/inverse` (also called from the EXP plugin). HALpR \(q=1\) vs \(q=2\) changes sparsity vs quadratic IRLS. For \(q=2\) the IRLS weight scale is \(\max|f|^2\) (polarity-invariant peak); a zero frame returns \(z=0\). Group Lasso requires a lead field whose column count is a multiple of 3. Related DOI on the HALpR class: [10.1016/j.clinph.2023.12.001](https://doi.org/10.1016/j.clinph.2023.12.001).

## Choosing a method (practical)

| Situation | Reasonable first try |
|-----------|----------------------|
| Static map, linear, fast | `mne` or `dspm` |
| Single-dipole-like peak, standardized | `eloreta` or sLORETA (`MethodParams.method_type`) |
| Sparse / hierarchical prior | `ias`, then `ramus` if you have a multiresolution decomposition |
| Time series with process noise | class `kalman` or GUI Kalman (DTI \(Q\) → GUI only) |
| Neural mass / parameter tracking | `ukfnmm` (class; Inverse tools → **UKF-NMM (class solver)** on every shipped profile) |
| Scanning one dipole per voxel | `dipolescan` (read GoF, not amplitude) |
| Adaptive spatial filter | `beamformer` |

Synthetic `L` in `+tests` checks shapes and dispatch, not clinical accuracy.

## Frame loop (class path)

`utilities.inverse.run_frame_loop`:

1. Filter / normalize measurements
2. Optional `initialize(L, f_data)`
3. Optional `precompute(L[, procFile])`
4. Per frame: `invert(f, L, procFile, …)`
5. Optional `smoother`, `terminateComputation`, post-process → `zef.reconstruction`

## Related

- Class APIs: [`+inverse/README.md`](../+inverse/README.md)
- Orchestration: [`src/inverse/README.md`](../src/inverse/README.md)
- Typeset chapters: [`documentation/`](../documentation/README.md)
- Citations collected: [`CITATION.md`](../CITATION.md)
- Numbers vs upstream: [`upstream.md`](upstream.md)
