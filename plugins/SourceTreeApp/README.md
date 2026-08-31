# plugins/SourceTreeApp

## Folder purpose

**Forward tools → Source tree tool**: App Designer tree of **Jansen–Rit** neural-mass nodes for forward simulation (not an inverse UKF/NMM solver). Edit a directed tree, simulate nodal signals, publish delay-aligned time courses, and optionally project through `zef.L` to synthetic measurements.

## Main contents

| Group | Files | Role |
|-------|--------|------|
| Start / UI | `zef_start_source_tree_tool`, `zef_open_source_tree`, `zef_source_tree_app.mlapp` (if present) | Menu entry + window |
| Defaults | `zef_init_jr_nodedata`, `zef_init_signal_general_data` | Per-node JR params + global signal (fs, pulse, loops, …) |
| Tree ↔ struct | `zef_build_source_tree`, `zef_rebuild_source_tree`, `zef_source_tree_add_child`, `zef_source_tree_addnode_pushed`, `zef_source_tree_addroot_pushed`, `zef_source_tree_deletenode_pushed`, `zef_source_tree_reset_pushed`, `zef_source_tree_selection_changed`, `zef_source_tree_cell_edited`, `zef_source_tree_get_selected`, `zef_cbtreenode_delete_node` | Sync UI tree with `zef.source_tree` |
| Simulate / publish | `zef_simulate_jr_tree`, `zef_publish_jr_tree_delays`, `zef_source_tree_simulate_signal_pushed`, `zef_source_tree_plot_signal_pushed` | ode45 JR (no transport delays in simulate) → absolute-time NaN-padded publish |
| Measurements / plot | `zef_simulate_measurements_from_source_tree`, `zef_plot_outPub`, `zef_plot_selected_source_to_axes_stem`, `zef_PlotSourceButton_Callback` | Optional `L` projection + visualization |
| Tables | `zef_update_signal_parameters_table` | Signal-parameter table ↔ `zef` |

## Code functionality

1. Open tool → restore/edit `zef.source_tree`.
2. **Simulate signal** → `zef_simulate_jr_tree` (looped feedback passes; **no** axonal transport delays in this step).
3. **Publish** → `zef_publish_jr_tree_delays` (NaN-padded absolute-time shifts between nodes).
4. Optional **measurements** → nearest `source_positions` columns of `zef.L` × published signals → `zef.measurements`.

**Needs for measurement projection:** `zef.L`, `zef.source_positions`. Tree edit alone does not require a lead field.

## Workflow context

```
Forward tools → Source tree tool
  → JR simulate / publish
  → optional synthetic measurements
  → Inverse tools (any method) on zef.measurements
```

INI callback: `zef_start_source_tree_tool` on profiles that register it (default head includes Source tree among Forward tools when configured).

## Usage instructions

```matlab
zef_start_source_tree_tool;
% Add root/child nodes → edit JR params → Simulate signal → Publish
% Optional: simulate measurements when L exists
```

## Important notes

- Forward neural-mass simulator — not UKFNMM / SESAME inverse plugins.
- Simulate step ignores transport delays; Publish applies delay alignment.
- Large trees + high `fs` can be slow under `ode45`.

## Developer guidance

- Keep tree schema changes (`zef.source_tree`) documented in init helpers and rebuild logic together.
- Prefer extending publish/measurement helpers over embedding `L` math in UI callbacks.
- Pitfall: expecting inverse-quality physiology from untuned JR parameters on a coarse source grid.
