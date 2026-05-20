# sn2zef — SimNIBS to Zeffiro Interface

MATLAB package for converting SimNIBS data into formats usable by the Zeffiro Interface (ZEF). The main pipeline (`run`) is **mesh-based**: it reads the SimNIBS Gmsh `.msh` file directly and writes per-tissue STLs, parcellation points, and a ZEF import script. A companion utility (`export_from_gmsh_mesh`) is the same idea without atlas/import-script generation.

**Package namespace:** `utilities.sn2zef`

### Entry points at a glance

- **Main pipeline** (Gmsh mesh → STLs, atlas, and `import_segmentations.zef`):
  ```matlab
  utilities.sn2zef.run(zef, subject_id, outFolder, inflation_parameter, options)
  ```
  Requires: `SIMNIBS_HOME` only. Loads `m2m_<subject_id>/<subject_id>.msh` and `m2m_<subject_id>/final_tissues_LUT.txt`. `zef` and `inflation_parameter` are accepted for back-compat and ignored.

- **STL-only mesh export** (Gmsh `.msh` + tissue listing → compartment STLs and full mesh MAT/HDF5; no `.zef` script, no atlas):
  ```matlab
  [meshStruct, tissueTable] = utilities.sn2zef.export_from_gmsh_mesh(meshFile, tissueListingFile, kwargs)
  ```

Other functions: `save_atlas_points` (mesh -> parcellation points .dat; used by `run`), `meshLoadGmsh4` (load Gmsh 2.x/4.x), `readSNLUT` (read `final_tissues_LUT.txt`). The legacy volume-based helpers (`export_segmentation_meshes`, `extract_SimNIBS_surfaces`, `exportSegmentationSTLs`, `run_and_print_command`, `+transforms/`) are kept for reference but are not on the active `run` code path anymore.

---

## Why mesh-based?

The SimNIBS `.msh` file is already in **scanner RAS** at 1 mm. Orientation and scale therefore match the FreeSurfer surface frame of the same subject — only a translation is needed to bring the two together, because `fs2zef` calls `mris_convert` without `--to-scanner` and keeps its surfaces in **FreeSurfer surface (tkr) RAS**:

```
surface_RAS = scanner_RAS - cras_fs
```

where `cras_fs = [c_r; c_a; c_s]` comes from the FreeSurfer T1 MGZ header (`mri/T1.mgz`, falling back to `mri/orig.mgz`). `run` reads that CRAS once, subtracts it from `mesh.nodes`, and writes STLs and atlas tetra centers in the translated frame. Both outputs therefore land in the same surface RAS as fs2zef, and the generated `import_segmentations.zef` still omits `affine_transform` from every row (`m/zef_import_segmentation.m:124` defaults to identity).

If the FreeSurfer subject folder cannot be located, the translation is skipped (with a warning) and the mesh stays in scanner RAS. Pass `options.freesurfer_subject_folder = ""` to opt out explicitly.

This follows the logic of the reference example
`zeffiro_may_2026/+utilities/+simnibsToZef/main.m` (and `test_2.m`), which also loads the mesh directly and writes nodes without any non-translation transform.

---

## Main pipeline (`run`)

### Requirements

- **SIMNIBS_HOME** — root directory; subject data in `m2m_<subject_id>`.
- **SUBJECTS_DIR** (optional but recommended) — FreeSurfer subjects directory; used to look up `mri/T1.mgz` for the surface-RAS translation. If unset or the file is missing, the translation is skipped with a warning and the mesh stays in scanner RAS.
- **FREESURFER_HOME** (optional) — needed only so MATLAB's path picks up `MRIread`; if it's already on path the env var is not required.

### Input files (in `SIMNIBS_HOME/m2m_<subject_id>/`)

- `<subject_id>.msh` — SimNIBS Gmsh mesh (preferred name). If absent, a single `.msh` in the folder is used; multiple candidates raise an error.
- `final_tissues_LUT.txt` — label lookup table (label number, name, R, G, B, A).

### Usage

```matlab
utilities.sn2zef.run(zef, subject_id, outFolder, inflation_parameter, options)
```

**Arguments:**

- **zef** — Accepted for API back-compat. **Not used.**
- **subject_id** — (string) Subject ID. The mesh is located in `SIMNIBS_HOME/m2m_<subject_id>/`.
- **outFolder** — (string) Directory where outputs are written. Created if it does not exist.
- **inflation_parameter** — Accepted for API back-compat. **Not used** (SimNIBS meshes are already smoothed at production time).
- **options** — (struct, optional)
  - `verbose` — (logical, default `false`) Print progress.
  - `include_atlas` — (logical, default `true`) Write parcellation points and append `atlas_points_filename` to every segmentation row. Set to `false` to omit atlas point imports.
  - `stl_output_format` — (`'binary'` (default) | `'text'`) Passed to `stlwrite`.
  - `freesurfer_subject_folder` — (string) Path used to look up `mri/T1.mgz` (or `mri/orig.mgz`) for the surface-RAS translation. Defaults to `SUBJECTS_DIR/<subject_id>`. Pass `""` to skip the translation entirely.

**Outputs (in `outFolder`):**

- One `<Tissue_Name>.stl` per tissue label (triangles where `triangle_regions == tissue_label + 1000`).
- `sn_atlas_points.dat` (when `include_atlas` is true).
- `electrodes.dat` — copied from `+utilities/+fs2zef/data/electrodes.dat` if available; otherwise skipped with a warning.
- `import_segmentations.zef` — ZEF import script. Sensor + box header followed by one segmentation line per STL: `name`, `filename`, `merge` (1 for `'rh'`/`'right'` names, 0 otherwise), `sigma 1.79`, `activity 0`, `color`, `inflate 0`, and (when atlas is enabled) `atlas_points_filename`. No `affine_transform` is written — the importer treats absence as identity.

Segmentation rows are sorted by name and merge value for deterministic output.

### Atlas data layout

`save_atlas_points` writes `sn_atlas_points.dat`, an ASCII matrix consumed by the `.dat` branch of `m/zef_import_parcellation_points.m`. It contains one row per non-zero tetrahedron: `[vertex_index_0based, x, y, z]` where the point is the tetra centroid in the same coordinate frame as the STL nodes.

This matches the in-memory atlas shape produced by `test_2.m` (`point_labels = tetra_labels`, points = `[non_zero_idx - 1, tetra_centers]`).

---

## STL-only mesh export (`export_from_gmsh_mesh`)

Use this when you only need per-compartment STLs and full-mesh MAT/HDF5, without a `.zef` script or atlas files.

### Usage

```matlab
[meshStruct, tissueTable] = utilities.sn2zef.export_from_gmsh_mesh(meshFile, tissueListingFile, kwargs)
```

**Key kwargs:** `outputFolder`, `dateTimeFormat`, `labelNameStr`, `labelStr`, `stlOutputFormat`, `subjectName`. See the function help for full details.

**Outputs (when `outputFolder` is given):**

- Subfolder `mesh_export.<subjectName>.<datetime>` containing:
  - One `<SafeName>.triangles.stl` per compartment (SimNIBS encoding: triangle region = tissue label + 1000).
  - `wholemesh.mat` with `nodes`, `triangles`, `triangleLabels`, `tetra`, `tetraLabels`.
  - `wholemesh.hdf5` with the same data under `/mesh/*`.

---

## Supporting functions

### `save_atlas_points`

```matlab
pts_filename = utilities.sn2zef.save_atlas_points(mesh, out_folder)
```

Builds a parcellation points file from the tetra centroids. No coordinate transformation is applied. Used by `run`; can be called directly when atlas points are needed for an existing mesh.

### `readSNLUT`

```matlab
lut = utilities.sn2zef.readSNLUT(folderPath)
```

Reads `final_tissues_LUT.txt` (space-separated columns: label number, label name, R, G, B, A; lines starting with `#` are comments). Returns a struct with fields `No`, `Name`, `R`, `G`, `B`, `A`.

### `meshLoadGmsh4`

```matlab
m = utilities.sn2zef.meshLoadGmsh4(fileName)
```

Loads a Gmsh mesh (version 2.x or 4.x, binary or ASCII) into a struct with fields `nodes`, `triangles`, `triangle_regions`, `tetrahedra`, `tetrahedron_regions` (and optionally `node_data`, `element_data`, `element_node_data`). Origin: SimNIBS `mesh_load_gmsh4.m`.

### Legacy volume-based helpers (not on the active code path)

The following remain in the package for back-compat but are no longer invoked by `run`. Prefer the mesh-based path above.

- `export_segmentation_meshes` — volume-based STL extractor (Brainstorm-driven marching cubes from `final_tissues.nii.gz`, plus optional `mri_coreg`/`mri_vol2vol` alignment).
- `extract_SimNIBS_surfaces` — standalone marching-cubes extractor.
- `exportSegmentationSTLs` — deprecated wrapper around `export_segmentation_meshes`.
- `run_and_print_command` — shell command runner used by the volume helpers.
- `+transforms/compute_simnibs_to_freesurfer_translation` — header-based SimNIBS↔FreeSurfer translation.

---

## File layout

```
+utilities/+sn2zef/
├── run.m                          % Main pipeline (mesh-based)
├── save_atlas_points.m            % Atlas point writer used by run
├── save_volume_atlas_points.m     % Atlas point writer used by legacy volume path
├── export_from_gmsh_mesh.m        % STL-only mesh export
├── readSNLUT.m                    % Read final_tissues_LUT.txt
├── meshLoadGmsh4.m                % Load Gmsh .msh
├── export_segmentation_meshes.m   % (legacy, volume-based)
├── exportSegmentationSTLs.m       % (legacy wrapper)
├── extract_SimNIBS_surfaces.m     % (legacy marching cubes)
├── run_and_print_command.m        % (legacy shell runner)
├── README.md                      % Package overview (this file)
└── +transforms/
    └── compute_simnibs_to_freesurfer_translation.m  % (legacy)
```

---

## MATLAB help

- `help utilities.sn2zef.run`
- `help utilities.sn2zef.save_atlas_points`
- `help utilities.sn2zef.export_from_gmsh_mesh`
- `help utilities.sn2zef.meshLoadGmsh4`
- `help utilities.sn2zef.readSNLUT`
