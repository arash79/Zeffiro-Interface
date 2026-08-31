# plugins/NSE_tool/mlapp

## Folder purpose

App Designer layout for the NSE (Navier–Stokes / hemodynamic) Multi-tools plugin. Callbacks and solvers live in `../m` and `src/forward/nse`.

## Main contents

| File | Role |
|------|------|
| `zef_nse_app.mlapp` | NSE tool UI instantiated by `zef_nse_tool_window` |

## Code functionality

Defines widgets for solver type, domains, pulse, ROI, and action buttons. `zef_nse_tool_window` attaches callbacks (Solve → `zef_nse_run_solver`, plots, interpolate, sigma, …). Theme/layout may be polished via `zef_ui_*` helpers after open.

## Workflow context

```
zef_nse_tool_start → zef_nse_tool_window → this mlapp
  → src/forward/nse (types 1–2, 4–7) or plugin haemodynamic type 3
```

## Usage instructions

```matlab
zef_nse_tool_start;
```

Do not run the `.mlapp` alone for a full solve. Requires vessel mesh fields (`nodes`, `tetra`, `domain_labels`, `mvd_length`) and typically the `multicompartment_head_nse` profile for menu visibility.

## Important notes

- Does not compute `zef.L`.
- Display required for the App Designer UI.

## Developer guidance

- After App Designer re-export, re-test Solve and plot buttons — MATLAB exports can drop callbacks.
- Keep widget tags stable for `zef_nse_tool_window` handle wiring.
- Pitfall: expecting the tool to populate `zef.L`.
