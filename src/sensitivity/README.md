## Folder purpose

Monte-Carlo probe of an inverse method on an existing `zef` (lead field + sources + measurements), without replacing `zef.reconstruction` on the main path. Study scripts under `+examples/+studies/+santtus_peeling_article` use older `zef_sensitivity_map_*` helpers instead of this file.

## Main contents

Single entry point: `zef_sensitivity_run.m`. Work is delegated to `utilities.sensitivity.run_monte_carlo` and `utilities.sensitivity.aggregate_statistics`; method capability checks live in `utilities.sensitivity.method_capability`.

## Code functionality

1. Checks `zef.L` and `zef.source_positions`.
2. Resolves active sources with `zef_processLeadfields`.
3. For RAMUS, may call `zef_make_multires_dec` (capability check).
4. Delegates to `utilities.sensitivity.run_monte_carlo`, which repeatedly calls `zef_inverse_run` (local or cluster).
5. Aggregates with `utilities.sensitivity.aggregate_statistics`.

Name-value options: `MethodParams`, `execution` (`"local"`/`"cluster"`), `ClusterProfile`, `NumberOfRuns`, `NoiseLevelDb`, `DiffType` (`"L2"`/`"minabs"`), `DispersionRadius`, `SourceAmplitude`, `SourceMask`, `IsolatedFramesPerProbe`, `MaxProbesPerBatch`.

## Workflow context

Call after a forward run (`zef.L`, `zef.source_positions`) with a registered inverse id (`'mne'`, `'eloreta'`, …). There is **no menu item** in `zef_menu_tool` for this file.

## Usage instructions

```matlab
[stats, run] = zef_sensitivity_run(zef, "mne", ...
    "NumberOfRuns", 50, "execution", "local", "NoiseLevelDb", -30);
```

## Important notes

- Does not write the main-path `zef.reconstruction` the way a normal inverse GUI run does; results come back as `stats` / `run`.
- Distinct from the peeling-article helpers under `+examples/+studies/+santtus_peeling_article`.
- Supported class ids (see `utilities.sensitivity.method_capability`): linear `csm`/`dspm`/`sloreta`/`sloreta3d`/`sbl`/`mne`/`wmne`/`eloreta`; iterative `dipolescan`/`beamformer`/`ias`/`ramus`/`halpr`/`grouplasso`; stateful `kalman`/`kf`. **Unsupported:** `ukfnmm`/`ukf_nmm` and every `legacy_*` id.

## Developer guidance

New inverter: extend `utilities.sensitivity.method_capability` and the inverse registry, not this wrapper. Keep option names aligned with `+utilities/+sensitivity/run_monte_carlo.m`.
