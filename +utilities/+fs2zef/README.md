# `utilities.fs2zef` — FreeSurfer volumes → Zeffiro surfaces

Converts FreeSurfer `mri/*.mgz` labels (and optional `surf/` meshes) into ASCII/STL surfaces plus `import_segmentation.zef`. Call as `utilities.fs2zef.run` after `addpath` of the project root. Do not `addpath('+fs2zef')`.

This package does **not** mesh or build a lead field. After conversion, import the `.zef` into a Zeffiro session, then mesh as usual.

## What must exist on disk

| Requirement | Role |
|-------------|------|
| `FREESURFER_HOME` | Installation root; `run` errors if unset (`fs2zef:NoFreeSurferHome`) |
| `SUBJECTS_DIR/<subject_id>/` | Subject folder; must contain `mri/` |
| `SUBJECTS_DIR/<subject_id>/mri/<seg>.mgz` | Each file in `segmentation_files` |
| FreeSurfer binaries on PATH | `run` sources `SetUpFreeSurfer.sh` then calls `+scripts/makeParcellation.sh` (`mri_segstats`, `mri_mc`, `mris_convert`) |
| Optional `surf/lh.pial`, `rh.pial`, `lh.white`, `rh.white` | Copied when `include_surfaces` is true |
| Optional `mri/orig.mgz` | Default reference for CRAS translation (`compute_transforms`) |

`run` also calls `environment.setup_freesurfer_env` then `validate_environment`. Missing `mri_mc` / `mri_segstats` / `mris_convert` fails validation.

## Public entry

```matlab
setenv('FREESURFER_HOME', '/usr/local/freesurfer');
setenv('SUBJECTS_DIR', '/path/to/subjects');

out = utilities.fs2zef.run("subject01", "aseg.mgz", "/output/fs2zef");

% Extra volumes (e.g. thalamic nuclei):
out = utilities.fs2zef.run("subject01", ...
    ["aseg.mgz"; "ThalamicNuclei.v13.T1.FSvoxelSpace.mgz"], ...
    "/output/fs2zef", ...
    "output_format", "stl", ...
    "merge_left_right", true);
```

### Arguments (`run`)

| Argument | Meaning |
|----------|---------|
| `subject_id` | Folder name under `$SUBJECTS_DIR` |
| `segmentation_files` | Column string array of `.mgz` **filenames** in `mri/` (not full paths) |
| `output_dir` | Created if missing |
| `output_format` | `'ascii'`, `'stl'`, or `'both'` (default `'both'`) |
| `compute_transforms` | CRAS translation vs `reference_volume` (default true) |
| `reference_volume` | `.mgz` in `mri/` (default `'orig.mgz'`) |
| `include_surfaces` | Convert `lh/rh.pial` and `lh/rh.white` (default true). White is written as `*.wm` |
| `include_skull_skin` | Declared (default true) — **not read** by `run` (see Gaps) |
| `electrode_file` | Copied to `ascii/` and `mesh/` as `electrodes.dat`. Empty → `+fs2zef/data/electrodes.dat` |
| `merge_left_right` | true: display name is the base, `merge=0/1` for L/R; false: names keep L/R, `merge=0` |
| `verbose` | Progress prints (default true) |

Returns `output_info` with `meshes_created`, `zef_import_file` (cell of paths), `warnings`, `elapsed_time`.

## Coordinate frame

Surfaces from `mri_mc` / `mris_convert` are FreeSurfer **surface (tkr) RAS**, millimetres. Specialized volumes (e.g. thalamic nuclei) may not share `orig.mgz` CRAS. When `compute_transforms` is true, `generators.generate_zef_import` writes a 4×4 **translation-only** `affine_transform` on each segmentation line (`transforms.compute_affine_transform`: `dx = source_c_r - target_c_r`, same for S/A). That is not a full RAS-to-RAS rotation.

Zeffiro applies `affine_transform` at mesh processing (`zef_process_meshes`). Do not also rotate the ASCII/STL files.

## Output layout

```
<output_dir>/
  ascii/*.asc              % if ascii or both
  ascii/electrodes.dat
  ascii/import_segmentation.zef
  mesh/*.stl               % if stl or both
  mesh/electrodes.dat
  mesh/import_segmentation.zef
```

Each `.zef` is a CSV of `type,sensors` / `type,box` / `type,segmentation,...` rows. Sigma/activity/color come from FreeSurfer LUT + `config.compartment_mappings`. Right-hemisphere rows get `merge=1` when `merge_left_right` is true.

`run`’s verbose “next step” prints `zef = zef_import(...)`. That helper is **not** the segmentation importer. Use:

```matlab
zef = zeffiro_interface('start_mode', 'nodisplay', ...
    'import_to_new_project', out.zef_import_file{1});
% or, into an already-open session:
zef = zeffiro_interface('import_to_existing_project', out.zef_import_file{1});
zef = zef_create_finite_element_mesh(zef);
```

`import_to_new_project` calls `zef_start_new_project` then `zef_import_segmentation` + `zef_build_compartment_table`. Paths inside the `.zef` are prefixed with `./<output_dir>/ascii` or `./<output_dir>/mesh` relative to the **current working directory**.

## Subpackages

| Folder | Role |
|--------|------|
| `+config/` | `compartment_mappings` (sigma/activity keywords); `default_config` / `parcellation_schemes` used by `test_unified_pipeline`, not by `run` |
| `+environment/` | `setup_freesurfer_env`, `validate_environment` |
| `+generators/` | `generate_zef_import` writes the `.zef`; `save_dats` / `save_color_tables` for atlas extras |
| `+readers/` | LUT, aseg stats, ASCII mesh/label, `mri_info` centers |
| `+scripts/` | `makeParcellation.sh` — one `.mgz` → one surface per label |
| `+transforms/` | CRAS translation matrix; apply to a mesh file |
| `data/` | Built-in `electrodes.dat` and an unused template `.zef` |

## Gaps

- `include_skull_skin` is in `run`’s `arguments` block and help, but the body never branches on it. Skull/skin appear only if those labels exist in the chosen `.mgz` (or you add surfaces some other way).
- `config.default_config` fields (`parcellation_schemes`, `recon_all_flags`, retries, …) are **not** consumed by `run`.
- Verbose next-step still recommends `zef_import`, which is a tetrahedral-mesh importer in `src/gui/helpers`, not this `.zef` pipeline.
