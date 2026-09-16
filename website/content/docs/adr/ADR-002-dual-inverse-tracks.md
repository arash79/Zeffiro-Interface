# ADR-002: Dual inverse tracks

## Status

Accepted.

## Decision

There are two inverse implementations. They both read `zef.L` and measurements and write `zef.reconstruction`. They do **not** share solver code and are **not** required to match numerically.

| Track | How you run it | Code |
|-------|----------------|------|
| Legacy Inverse tools | Menu item without `(class solver)` | `plugins/*` iterations (`zef_KF`, `zef_ias_iteration`, …) |
| Class / cluster | `zef_inverse_run`, cluster jobs, or a menu labelled **(class solver)** | `inverse.*Inverter` via `zef_open_class_inverse` |

A **(class solver)** menu is a thin dialog around `zef_inverse_run`. The matching legacy menu, when it exists, still runs the plugin iteration.

Default-profile Inverse tools currently expose class-solver dialogs for eLORETA, UKF-NMM, HALpR, Group Lasso, MNE, IAS, RAMUS, CSM, Kalman, Beamformer, and Dipole Scan. Methods that still have a plugin iteration keep that menu as well.

Kalman DTI structural process-noise \(Q\) exists only on `plugins/Kalman`. Class Kalman does not implement that path.

## Why

The class track is the programmable / cluster API (`utilities.cluster.inverse_method_registry`). The legacy track is the historical GUI. Merging them would change reconstructions for existing plugin users and would drop capabilities that exist on only one side.

## Consequences

- Do not point a legacy Start button at a class inverter, or a class-solver Start button at a `*_iteration`, unless that product change is explicit and tested.
- `tests.integration.ClassVsLegacyTest` checks that both tracks produce a nonempty reconstruction. It does not require bit-exact parity.
- Scripts and HPC jobs should call `zef_inverse_run` with a registry id, not a GUI callback string.
