# `utilities.sn2zef` — SimNIBS tissues → Zeffiro STLs

Extracts **closed** compartment surfaces from SimNIBS `final_tissues.nii.gz` (voxel tetrahedral decomposition via Brainstorm-style `zef_bst_get_atlas_surfaces`), not from the Gmsh `.msh`. Public entry: `utilities.sn2zef.run`.

`meshLoadGmsh4.m` is **vendor code** (Thielscher / Antunes SimNIBS Gmsh reader), not a Zeffiro-authored parser. Keep its original license header. The volume pipeline does not call it; only `export_from_gmsh_mesh` does.

## What must exist on disk

| Requirement | Role |
|-------------|------|
| `SIMNIBS_HOME` | `run` looks for `SIMNIBS_HOME/m2m_<subject_id>/` |
| `m2m_<id>/final_tissues.nii.gz` | Segmentation volume |
| `m2m_<id>/final_tissues_LUT.txt` | Tissue names/colors (`readSNLUT`) |
| `FREESURFER_HOME` | Needed by `export_segmentation_meshes` (`MRIread`, optional `mri_coreg`) |
| FreeSurfer subject dir with `mri/orig.mgz` | `options.freesurfer_subject_folder`, or `$SUBJECTS_DIR/<subject_id>` |
| A `zef` struct | Passed through for `zef_inflate_surface` fields (`inflate_strength`, GPU flags) |

`run` errors if `SIMNIBS_HOME` is empty (`sn2zef:NoSimnibsHome`), if the m2m folder or NIfTI is missing, or if the FreeSurfer subject folder is unset/missing.

## Public entry

```matlab
zef = zeffiro_interface('start_mode', 'nodisplay');  % any session struct is enough
opts = struct('verbose', true, 'include_atlas', true, 'atlas_voxel_stride', 4);
utilities.sn2zef.run(zef, "subject01", "/output/sn2zef", 0, opts);
```

`inflation_parameter` is Taubin iterations per tissue (`0` to skip). Large values on a full SimNIBS grid are slow (`sn2zef:SlowInflation` if `> 40` and voxel count `> 1e6`).

### Options struct on `run`

| Field | Default | Meaning |
|-------|---------|---------|
| `verbose` | false | Progress |
| `include_atlas` | true | Write subsampled atlas points |
| `atlas_voxel_stride` | 4 | Subsample factor |
| `force_coreg` | false | Collected by `run` — **not** an option of `export_segmentation_meshes` (see Gaps) |
| `freesurfer_subject_folder` | `$SUBJECTS_DIR/<id>` | Must contain `mri/orig.mgz` |

`run` has no return value. It writes files under `outFolder`.

## Coordinate frames

Worker: `export_segmentation_meshes` (`alignment_mode` `'translation'` **default**, or `'coregistration'`).

| Mode | Volume meshed | Vertex transform `T` | Affine returned |
|------|---------------|----------------------|-----------------|
| `translation` | Native `final_tissues.nii.gz` | SimNIBS NIfTI `vox2ras` | 4×4 header map from `transforms.compute_simnibs_to_freesurfer_translation` (for Zeffiro `affine_transform`) |
| `coregistration` | `mri_coreg` + `mri_vol2vol` → `final_tissues_aligned.nii.gz` | FS-style `Ttrans * vox2ras * coordSwap` (CRAS shift + dim swap) | `[]` (vertices already in FreeSurfer RAS) |

`run` currently calls the worker **without** `alignment_mode`, so the default is **translation**. It also **discards** the returned `affine_matrix` (`[~, vertex_info] = ...`) and writes `import_segmentations.zef` **without** `affine_transform`. Vertices in the STLs are therefore whatever `T` the worker applied (SimNIBS RAS in the default mode), not automatically FreeSurfer tkr RAS unless you call `export_segmentation_meshes` yourself with `'coregistration'`.

The wrapper `exportSegmentationSTLs` does pass `'coregistration'` (as a struct — see Gaps).

## Output files (`run`)

```
<outFolder>/
  <Tissue_Name>.stl          % one per LUT label except names containing "domain fill"
  electrodes.dat             % copy of +fs2zef/data/electrodes.dat if present
  sn_atlas_points.dat        % when include_atlas and write succeeded
  import_segmentations.zef   % note the plural filename
```

Each segmentation row: `sigma=1.79` (CSF-like default for **every** SimNIBS tissue — not the fs2zef `compartment_mappings` table), `activity=0`, `inflate=0`, RGB from the LUT, `merge=1` if the name contains `rh` or `right`. Atlas path is appended when the points file exists. Edit conductivity in the Segmentation tool after import if you need tissue-specific σ.

## Import into Zeffiro

```matlab
zef = zeffiro_interface('start_mode', 'nodisplay', ...
    'import_to_new_project', fullfile(outFolder, 'import_segmentations.zef'));
zef = zef_create_finite_element_mesh(zef);
```

Filenames in the `.zef` are **absolute** paths to the STLs. Electrodes line points at `<outFolder>/electrodes.dat` (EEG, filetype `points`).

## Other functions

| Function | Role |
|----------|------|
| `export_segmentation_meshes` | Volume → STL worker (use this if you need `alignment_mode` / affine) |
| `exportSegmentationSTLs` | Wrapper intending coregistration mode |
| `readSNLUT` | Parse `final_tissues_LUT.txt` |
| `save_atlas_points` / `save_volume_atlas_points` | Parcellation point dumps |
| `extract_SimNIBS_surfaces` | Lower-level volume-label surfaces (used internally / Brainstorm-style atlas) |
| `export_from_gmsh_mesh` | Legacy Gmsh `.msh` sheets (open, single-sided). Prefer the volume pipeline |
| `run_and_print_command` | `system` + echo for `mri_coreg` / `mri_vol2vol` |
| `+transforms/compute_simnibs_to_freesurfer_translation` | Header RAS→RAS matrix for Zeffiro `affine_transform` |

## Gaps

- `run` help text still describes “always `mri_coreg`” and “no affine in the `.zef` because vertices are already tkr-RAS”. The call does not pass `alignment_mode` (default **translation**) and drops the affine.
- `run` forwards `'force_coreg', ...` to `export_segmentation_meshes`, which has no such name-value (only `alignment_mode`, `verbose`, `include_atlas`, `atlas_voxel_stride`). MATLAB `arguments` will reject the extra name.
- `exportSegmentationSTLs` passes a **struct** as the 6th positional argument; the worker expects name-value options, not a positional struct.
