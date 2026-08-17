# tools/plugins/NSE_tool/mlapp

## Folder purpose

App Designer layouts for the NSE (Navier–Stokes / hemodynamic) Multi-tools plugin. Callbacks and solvers live in `../m` and `src/forward/nse`.

## Main contents

| File | Role |
|------|------|
| `zef_nse_app.mlapp` | Primary NSE tool UI |
| `zef_nse_tool_app.mlapp` | Alternate / legacy app export name — confirm which `zef_nse_tool_window` instantiates |

## Code functionality

Defines widgets for solver type, domains, pulse, ROI, and action buttons. `zef_nse_tool_window` (in `m/`) instantiates the app and attaches callbacks (Solve → `zef_nse_run_solver`, plots, interpolate, …).

## Workflow context

`zef_nse_tool_start` → window → this mlapp → forward NSE solvers.

## Usage instructions

Do not run the `.mlapp` alone for a full solve:

```matlab
zef_nse_tool_start;
```

Edit in App Designer; keep callback names stable for the window script.

## Important notes

- Requires `multicompartment_head_nse` (or equivalent) profile for menu visibility.
- Does not compute `zef.L`.

## Developer guidance

- After re-export, re-test Solve and plot buttons; MATLAB exports can drop callbacks.
- Pitfall: editing the unused twin `.mlapp` while the window still loads the other.
