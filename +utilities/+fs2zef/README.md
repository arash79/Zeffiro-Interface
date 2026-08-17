# `utilities.fs2zef` — FreeSurfer → Zeffiro surfaces

## Folder purpose

Convert FreeSurfer `mri/*.mgz` label volumes (and optional `surf/` meshes) into ASCII/STL surfaces plus `import_segmentation.zef`. Does **not** mesh or build a lead field — import the `.zef` into Zeffiro afterward. Call as `utilities.fs2zef.run` with project root on the path (never `addpath('+fs2zef')`).

## Main contents

| Area | Role |
|------|------|
| `run.m` | Public pipeline entry |
| `+scripts/makeParcellation.sh` | FreeSurfer marching-cubes / convert |
| `+environment/` | `setup_freesurfer_env`, `validate_environment` |
| `+readers/` / `+generators/` / `+transforms/` | I/O, `.zef` generation, CRAS affine |
| `+config/` | Compartment mappings / defaults |
| `data/` | Default `electrodes.dat`, template `.zef` |
| `test_unified_pipeline.m` | In-package smoke test |

## Code functionality

**Requires:** `FREESURFER_HOME`, `SUBJECTS_DIR/<id>/mri/<seg>.mgz`, FreeSurfer binaries (`mri_segstats`, `mri_mc`, `mris_convert`). Optional `surf/lh.pial` etc. and `orig.mgz` for CRAS.

**`run(subject_id, segmentation_files, output_dir, options…)`:** validate env → shell parcellation → transforms → write surfaces + `import_segmentation.zef` (+ electrodes copy).

Options include `output_format` (`ascii`/`stl`/`both`), `merge_left_right`, `include_surfaces`, `electrode_file`, `verbose`. Some declared options (e.g. `include_skull_skin`) may be unused — check Gaps in code comments.

## Workflow context

```
utilities.fs2zef.run → output folder → zef_import_segmentation / zeffiro_interface import
  → src/mesh → src/forward
```

Related converters: `brainstorm2zef`, `sn2zef`, `duneuro2zef`.

## Usage instructions

```matlab
setenv('FREESURFER_HOME', '/usr/local/freesurfer');
setenv('SUBJECTS_DIR', '/path/to/subjects');
out = utilities.fs2zef.run("subject01", "aseg.mgz", "/output/fs2zef");
```

Then import the generated `.zef` into Zeffiro.

## Important notes

- Relative FreeSurfer failures usually mean unset env or missing binaries.
- Does not populate `zef` in memory — file outputs only.
- Electrode file defaults to package `data/electrodes.dat`.

## Developer guidance

- Keep shell script args and `run` options in sync.
- Extend compartment mappings in `+config`, not with hard-coded names in `run`.
- Prefer `test_unified_pipeline` before changing generators.
