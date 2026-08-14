# `tools` — optional GUI plugins

The only first-party tree under `tools/` is **`plugins/`**. At startup, `zeffiro_interface` puts that folder on the MATLAB path with `addpath(genpath(.../tools/plugins))`. Plugin functions are then called by the short names in `profile/<name>/zeffiro_plugins.ini` (`zef_kf_start`, `ias_map_estimation`, …).

This is **not** a MATLAB package (`+tools`). It is also not the core runtime: mesh, lead field, figure windows, and `zef_*` session scripts live under `src/`. Class inverse solvers live under `+inverse` and are **not** what most Inverse-tools buttons construct.

## Why this folder exists

A GUI user needs extra windows (Kalman, Filter tool, Data Bank, DTI, NSE, tES optimization, …) that would clutter `src/` if they were always compiled into the main figure. Each plugin is a self-contained start function plus algorithm files. The active **profile** decides which of them appear on **Inverse tools**, **Forward tools**, **Multi tools**, and **Settings**.

## How to use it

1. Start Zeffiro (`zeffiro_interface`). The default profile is `multicompartment_head`.
2. Open a plugin from the menu bar. The exact labels and callbacks are listed in [plugins/README.md](plugins/README.md).
3. Or call the start function from MATLAB (the folder is already on the path), for example `zef_kf_start`.

A plugin directory that is **not** listed in the profile INI is still on the path; it just has no menu row.

## Related trees

| Location | Role |
|----------|------|
| `tools/plugins/` | This tree — GUI modules |
| `profile/*/zeffiro_plugins.ini` | Which plugins appear on which menu |
| `src/` | Core session, mesh, forward, figure tools |
| `+inverse` | Class solvers for `zef_inverse_run` / cluster |
| `+plugins` | MATLAB-package helpers some plugins call (ClassKF, ClassGMM) |

Read **[plugins/README.md](plugins/README.md)** next for the default Inverse/Forward/Multi tools list, what you need before Start, and how that differs from `zef_inverse_run`.
