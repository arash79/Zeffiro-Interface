# `+utilities` — converters, cluster inverse, shared helpers

This MATLAB package is the glue between Zeffiro sessions and everything that is not the GUI runtime: **importing** anatomy from Brainstorm / FreeSurfer / SimNIBS / Duneuro, **dispatching** class inverse jobs (local or cluster), and small I/O/struct helpers. Call it as `utilities.*` after `zeffiro_interface` (or `addpath` of the project root). Do not `addpath('+utilities')`.

Nothing here is a menu item except where a converter has its own plugin start (Brainstorm). Cluster inverse is the backend of `zef_inverse_run`.

## Inverse dispatch (what `zef_inverse_run` actually calls)

```
zef_inverse_run(zef, method_id, …)
  → src/inverse extracts a bundle (L, measurements, frames, params)
  → utilities.cluster.dispatch_inverse(bundle)
       class path: construct inverse.*Inverter
                   utilities.inverse.run_frame_loop
                   zef_postProcessInverseClassObj
       legacy path: feval(legacy_function) with zef in base
  → zef.reconstruction
```

Register new method ids in `+cluster/inverse_method_registry.m` (verified ids are listed in `+inverse/README.md`).

Batch / HPC:

```matlab
% See +cluster/+examples/eloreta_workflow.m and kalman_workflow.m
utilities.cluster.submit_inverse_jobs(...)
utilities.cluster.collect_inverse_results(...)
```

`configure_cluster_profile`, `create_batch_job`, `run_inverse_job`, `with_zef_in_base` are the job plumbing. You need the Parallel Computing Toolbox for parallel pools; cluster profiles are MATLAB's, not Zeffiro INI profiles.

## Anatomy converters

Each `*2zef` subpackage has a `run.m` (or `import_*`) that writes a Zeffiro-style folder: surfaces, `import_segmentation.zef`, often `electrodes.dat`. After conversion, start Zeffiro with `'import_to_new_project'` pointing at that `.zef`, then mesh as usual.

| Package | External tool | Entry |
|---------|---------------|--------|
| `utilities.fs2zef` | FreeSurfer `surf/` + `mri/aseg` | `utilities.fs2zef.run` |
| `utilities.sn2zef` | SimNIBS `final_tissues.nii.gz` (not the Gmsh `.msh`) | `utilities.sn2zef.run` |
| `utilities.brainstorm2zef` | Brainstorm protocol | `utilities.brainstorm2zef.run` / plugin start `zef_bst_plugin_start` |
| `utilities.duneuro2zef` | Duneuro FEM + EEG/MEG | `utilities.duneuro2zef.run` / `import_duneuro_project` |

SimNIBS `meshLoadGmsh4.m` is vendor code (Thielscher/Antunes); do not re-attribute it. FreeSurfer environment helpers live under `+fs2zef/+environment`.

Child READMEs in those packages should explain **that converter's flags, coordinate conventions, and output files**, not repeat Zeffiro startup.

## Other subpackages

| Package | Role |
|---------|------|
| `utilities.sensitivity` | Monte Carlo on inverse methods (`run_monte_carlo`, synthesize measurements) |
| `utilities.leadfield.lf_tag_from_lf_type` | Maps lead_field_type **1–5** to a tag (anisotropic 6–10 are not in this map) |
| `utilities.structs.copy_fields` | Used at startup to copy name-value args onto `zef` |
| `utilities.io` | `abspath`, `read_gitmodules` (for `zeffiro_setup`), `float_is_int`, reconstruction-from-EDF |
| `utilities.plotting` | Paper-style figure helpers for `+examples/+studies` |
| `utilities.dev` | Lint/indent/`get_mfile_paths` for maintainers |

## Scripting sketch

```matlab
addpath(fileparts(which('zeffiro_interface')));

% After a mesh + L + measurements:
[zef, run_result] = zef_inverse_run(zef, "eloreta", "execution", "local");
% equivalent guts:
%   bundle = … (see zef_inverse_extract_bundle)
%   result = utilities.cluster.dispatch_inverse(bundle);

% FreeSurfer → Zeffiro folder (see +fs2zef/README.md for real arguments)
utilities.fs2zef.run(...)
```

## See also

- `+inverse/README.md` — class solvers and registry ids
- `src/inverse/README.md` — bundle extraction
- `+utilities/+cluster/+examples/` — eloreta / Kalman / parameter sweep
- Root README — typical GUI workflow these converters feed into
