# NSE tool — App Designer layouts

Two apps:

| File | Role |
|------|------|
| `zef_nse_tool_app.mlapp` | Main **NSE tool** window (`zef_nse_tool_window`). **Solve system** → `zef_nse_run_solver`. |
| `zef_nse_app.mlapp` | Extra NSE widgets used by the same plugin (solver-type / field displays). |

Do not run the generated apps from the command line; start with **Multi tools → NSE tool** (`zef_nse_tool_start`). PDE details: `src/forward/nse`. Parent: [../README.md](../README.md).
