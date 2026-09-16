# ADR-003: Plugins versus shared kernels

## Status

Accepted.

## Decision

Shared inverse kernels that more than one caller needs live under `+inverse`:

- `inverse.gmm.*` — Gaussian-mixture fit used by class inverters and the JL GMM app’s advanced Start path
- `inverse.kf.*` — Kalman predict/update used by `inverse.KalmanInverter` and `inverse.UKFNMMInverter`

GUI plugins under `plugins/` may call those kernels. They must not be the only copy of the math.

## Why

Cluster jobs and tests construct class inverters without opening a plugin window. Putting the only implementation inside a GUIDE/App Designer folder made that path depend on GUI state.

## Consequences

- New Kalman / GMM numerics go in `+inverse/+kf` or `+inverse/+gmm`, not under `plugins/Kalman` or `plugins/GMMClustering`.
- `plugins.ClassGMM` / `plugins.ClassKF` must stay absent (`ArchitectureLayoutTest`).
- The two GMM GUIs (SP `plugins/GMModel`, JL `plugins/GMMClustering`) remain separate windows with different `zef` fields; they are not duplicate class inverters.
