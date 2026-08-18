# tools/plugins/SourceTreeApp

## Folder purpose

**Source tree tool**: a tree of Jansen–Rit neural-mass nodes (Cook et al. 2022, system 4.45) used to simulate coupled time courses and, optionally, EEG/MEG measurements through `zef.L`. Default-profile menu label: **Source tree tool**. This is a forward simulator, not `inverse.UKFNMMInverter` (which uses Jansen–Rit only as the inverse temporal model).

## Main contents

| File | Role |
|------|------|
| `zef_start_source_tree_tool.m` | INI / start → `zef_tool_start` |
| `zef_open_source_tree.m` / `zef_source_tree_app.mlapp` | App Designer window and callbacks |
| `zef_init_jr_nodedata.m` / `zef_init_signal_general_data.m` | Default node / global signal parameters |
| `zef_build_source_tree.m` / `zef_rebuild_source_tree.m` | Tree UI ↔ struct |
| `zef_simulate_jr_tree.m` | Coupled ode45 JR network (no transport delays) |
| `zef_publish_jr_tree_delays.m` | Apply delays when publishing signals |
| `zef_simulate_measurements_from_source_tree.m` | Lead-field projection of published signals |
| `jansen_rit_model.m` | Standalone single-node demo (opens figures; not used by the app) |

## Code functionality

1. Add root/child nodes; edit JR parameters, position, orientation, and connectivity in tables.
2. **Simulate signal** runs `zef_simulate_jr_tree` with `zef.source_tree_signal_parameters` (duration, sampling rate, external pulse, optional modulation, feedback loops).
3. Delays are applied only in `zef_publish_jr_tree_delays`, not inside the ODE.
4. **Simulate measurements** projects published node time courses through the nearest `zef.source_positions` column-triple of `zef.L`.

## Workflow context

```
Source tree tool → JR time courses on zef.source_tree
  → optional zef.measurements via zef.L
  → inverse methods (class or plugin)
```

UKFNMM inverse (`inverse.UKFNMMInverter`) does not open this window.

## Usage instructions

```matlab
zef_start_source_tree_tool;
% Add root → edit parameters → Simulate signal → Simulate measurements
```

Headless JR smoke test:

```matlab
tree.Root = struct('Text', 'Root', 'NodeData', zef_init_jr_nodedata());
gd = zef_init_signal_general_data();
gd.blockDuration_s.Value = 0.05;
gd.samplingRate_Hz.Value = 200;
out = zef_simulate_jr_tree(tree, gd);
```

## Important notes

- `jansen_rit_model.m` is a demo script; do not treat it as the app solver.
- Per-node noise is `NodeData.SourceNoiseStd` (the ODE also accepts a legacy `SourceNoise` field).
- `OutputGain` is in dB (`db2mag`).
- The App Designer binary `zef_source_tree_app.mlapp` is required to open the window.

## Developer guidance

Keep JR parameter names aligned with `nodedata_to_par` in `zef_simulate_jr_tree`. Do not merge this plugin into `inverse.UKFNMMInverter`. New node fields need both the table mapping and the NV getters.
