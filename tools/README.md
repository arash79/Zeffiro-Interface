# `tools` — optional GUI plugins

## Folder purpose

Optional GUI plugin tree for Zeffiro. The only first-party subtree is **`plugins/`**. Extra windows (Kalman, Filter tool, Data Bank, DTI, NSE, tES optimization, …) live here so they do not clutter `src/`. This is not a MATLAB package (`+tools`) and not the core runtime.

## Main contents

| Location | Role |
|----------|------|
| `tools/plugins/` | GUI modules (start function + algorithm files) |
| (related) `profile/*/zeffiro_plugins.ini` | Which plugins appear on which menu |
| (related) `src/` | Core session, mesh, forward, figure tools |
| (related) `+inverse` | Class solvers for `zef_inverse_run` / cluster |
| (related) `+plugins` | Package helpers some class solvers call (ClassKF, ClassGMM) |

## Code functionality

At startup, `zeffiro_interface` puts `tools/plugins` on the path with `addpath(genpath(...))`. Plugin functions are then called by the short names in `profile/<name>/zeffiro_plugins.ini` (`zef_kf_start`, `ias_map_estimation`, …). The active profile decides which appear on **Inverse tools**, **Forward tools**, **Multi tools**, and **Settings**.

Class inverse solvers under `+inverse` are not what most Inverse-tools buttons construct.

## Workflow context

A GUI user opens plugins from the menu bar after a normal session start. A plugin directory not listed in the profile INI is still on the path; it just has no menu row. Mesh, lead field, and figure windows remain under `src/`.

## Usage instructions

1. Start Zeffiro (`zeffiro_interface`). Default profile: `multicompartment_head`.
2. Open a plugin from the menu bar (labels/callbacks in `plugins/README.md`).
3. Or call the start function from MATLAB (folder already on the path), e.g. `zef_kf_start`.

## Important notes

Read `plugins/README.md` next for the default Inverse/Forward/Multi tools list, prerequisites before Start, and how that differs from `zef_inverse_run`.

## Developer guidance

Keep new GUI modules under `tools/plugins/` with a start function registered in the relevant `zeffiro_plugins.ini`. Prefer putting new inverse math in `+inverse` and registering it; keep plugins as thin GUI wrappers.
