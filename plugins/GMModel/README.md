## Folder purpose

Gaussian-mixture clustering of an **existing** reconstruction (SP tool). This is not an inverse solver: it needs `zef.reconstruction` already filled. Use it to turn a distributed map into a few equivalent dipoles / cluster centres.

## Main contents

- Start: `zef_GMModel_start.m` → `zef_GMModel_open` → `zef_GMModel_init` (defaults `max_n_clusters`, `credibility`, `frame_number`, … onto `zef.GMModel` if missing) → `zef_GMModel_window`
- Solver: `zef_cluster_reconstruction.m` / `zef_find_clusters.m`

## Code functionality

**Run** (`zef.GMModel.h_start`) Callback — not labelled Start:

```matlab
zef = zef_GMModel_update(zef); [zef.GMModel.cluster_centres,zef.GMModel.dipole_moments,~,zef.GMModel.Param] = zef_cluster_reconstruction(zef);
```

Needs: `zef.reconstruction` (cell uses `zef.GMModel.frame_number`); `zef.source_positions`; GMM options on `zef.GMModel`: `max_n_clusters`, `credibility`, `n_dynamic_levels`, `reg_param`, `max_n_iter`, `tol_val`. Does **not** read `zef.L` or `zef.measurements`.

Amplitude is peak-normalized, then split into `n_dynamic_levels` bands. The **lowest** band (`amp ≤ 1/n_dynamic_levels`) is discarded; clustering uses only the remaining sources as `[xyz, dipole_xyz]` rows. If that table has fewer rows than columns, it is tiled (`repmat`) until `fitgmdist` can run. `zef_find_clusters` then increases `K` from 1 until `max_n_clusters` or every point already has a unique label, using a χ² Mahalanobis cutoff (`chi2inv(credibility, 6)` on the 6-D rows). Cluster centres are the mean xyz of assigned points; dipole moments are the **sum** of the xyz components in that cluster (not the mean). Empty clusters are NaN.

Writes: `zef.GMModel.cluster_centres`, `dipole_moments`, `Param`. Does **not** overwrite `zef.reconstruction`.

## Workflow context

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **Gaussian Mixture Model (SP)** |
| `_legacy`, `_nse` | Inverse tools → **Gaussian Mixture Model (SP)** |
| asteroid_radar / asteroid_gravity | **not in those INIs** (they register the JL app only) |

INI callback: `zef_GMModel_start`. Window title: `ZEFFIRO Interface: Gaussian Mixture Model tool`.

`inverse.gmm` is unused from this GUI. The four **(class solver)** Inverse-tools entries call `zef_inverse_run`; this GMM window does not.

## Usage instructions

1. Fill `zef.reconstruction` from an inverse solver.
2. Open Inverse tools → Gaussian Mixture Model (SP).
3. Press Run (not labelled Start).

## Important notes

- Asteroid profiles register the JL app only, not this SP tool.
- Dipole moments are sums of xyz components, not means.
- Does not read `zef.L` or `zef.measurements`.

## Developer guidance

Preserve callback `zef_GMModel_start` and outputs on `zef.GMModel.*`. Keep Run callback wiring on `zef.GMModel.h_start`. `inverse.gmm` remains unused from this GUI.
