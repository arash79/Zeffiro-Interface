# Inverse sensitivity (`src/sensitivity`)

One function: run a Monte-Carlo probe of an inverse method on an existing `zef` (lead field + sources + measurements), without replacing `zef.reconstruction` on the main path.

This is **not** the EIT Sensitivity plugin (`tools/plugins/EITSensitivityTool`). Study scripts under `+examples/+studies/+santtus_peeling_article` use older `zef_sensitivity_map_*` helpers instead of this file.

## When to call it

After a forward run (`zef.L`, `zef.source_positions`) and with a registered inverse id (`'mne'`, `'eloreta'`, …). Optional from `zef_inverse_pipeline_run` when sensitivity is enabled.

There is **no menu item** in `zef_menu_tool` for this file.

## What it does

1. Checks `zef.L` and `zef.source_positions`.
2. Resolves active sources with `zef_processLeadfields`.
3. For RAMUS / HALpR / GroupLasso, may call `zef_make_multires_dec` (capability check in `utilities.sensitivity.method_capability`).
4. Delegates to `utilities.sensitivity.run_monte_carlo`, which repeatedly calls `zef_inverse_run` (local or cluster).
5. Aggregates with `utilities.sensitivity.aggregate_statistics`.

```matlab
[stats, run] = zef_sensitivity_run(zef, "mne", ...
    "NumberOfRuns", 50, "execution", "local", "NoiseLevelDb", -30);
```

Name-value options (from the `arguments` block): `MethodParams`, `execution` (`"local"`/`"cluster"`), `ClusterProfile`, `NumberOfRuns`, `NoiseLevelDb`, `DiffType` (`"L2"`/`"minabs"`), `DispersionRadius`, `SourceAmplitude`, `SourceMask`, `IsolatedFramesPerProbe`, `MaxProbesPerBatch`.

## Developer notes

- New inverter: extend `utilities.sensitivity.method_capability` and the inverse registry, not this wrapper.
- Keep option names aligned with `+utilities/+sensitivity/run_monte_carlo.m`.
