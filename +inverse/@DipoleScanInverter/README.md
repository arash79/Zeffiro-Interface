# inverse.DipoleScanInverter

Goodness-of-fit map: for each source, fit a dipole to whitened `f` and store `GoF = 1 - ‖f - L s‖²/‖f‖²` (free sources also encode direction / √3). Registry ids: `dipolescan`, `dipole_scan`. GUI: `legacy_dipolescan` → `zef_dipoleScan`.

## Files

| File | Role |
|------|------|
| `DipoleScanInverter.m` | `method_type`, `reg_type`, `reg_parameter`, `noise_cov`, SVD caches |
| `initialize.m` | `noise_cov = 10^(-SNR/10) * mean(f²) * I` if empty |
| `precompute.m` | `Chalf = sqrtm(C)`, cache whitening and per-source thin SVDs |
| `invert.m` | Batched `pagemtimes` path if caches exist; else per-source SVD/pinv loop |

## Parameters

- `method_type`: `"SVD"` (default) \| `"Pseudoinverse"`
- `reg_type`: `"None"` \| `"Basic"` (adds `reg_parameter` to singular values)
- `reg_parameter` (0.001)
- `noise_cov` optional

Lead field columns must be a multiple of 3 (`precompute` errors otherwise).

## Call

```matlab
[zef, r] = zef_inverse_run(zef, "dipolescan", "execution", "local", ...
    "MethodParams", struct("method_type", "SVD", "reg_type", "None"));
```
