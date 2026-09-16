# The `zef` session struct

Zeffiro does not use a class as the project object. Everything the GUI and most scripts share is one MATLAB struct, **`zef`**, typically in the base workspace.

This page lists fields that matter for meshing, forward, and inverse work. Visualization sliders, window positions, and similar chrome are omitted; they are created in `src/app/zef_init.m` and the various `zef_update_*` functions. Defaults below are from `zef_init` unless noted.

Handles (`zef.h_*`) are graphics objects. `zef_save` strips them before writing a `.mat` file (`zef_remove_object_handles`). Do not treat saved projects as a dump of live figure state.

## Identity and paths

| Field | Meaning |
|-------|---------|
| `program_path` | Repository root (folder of `zeffiro_interface.m`) |
| `code_path` | `src/` |
| `data_path` | `data/` (default folder for CLI paths with no directory) |
| `external_path` | `external/` |
| `profile_name` | Active INI profile folder under `profile/` (default `multicompartment_head`) |
| `current_version` | Project-format stamp written at init (currently `6.0`). User-facing product name is **Zeffiro Interface V2**. |
| `start_mode` | `"display"` / `"nodisplay"` / `"default"` |
| `save_file`, `save_file_path` | Last project MAT name and folder |

## Compartments

| Field | Meaning |
|-------|---------|
| `compartment_tags` | Cell of short tags; table rows are stored **in reverse** of this order |
| `<tag>_on` | Participates in mesh and plot |
| `<tag>_points` | Surface vertices, typically mm, `N×3` |
| `<tag>_triangles` | Faces, 1-based indices, `M×3` |
| `<tag>_sigma` | Conductivity used when packing `zef.sigma` |
| `<tag>_sources` | Integer Activity code: `-1` Bounding box / PML, `0` Inactive, `1` Constrained field, `2` Unconstrained field, `3` Active surface. Source placement uses `{1, 2}` only (`zef_get_active_compartments`). |
| `<tag>_priority` | Labeling priority (Segmentation table column 1) |
| `<tag>_scaling`, `_*_correction`, `_*_rotation` | Affine / Euler (degrees) applied in `zef_process_meshes` |
| `reuna_p`, `reuna_t` | Gathered active surfaces after `zef_process_meshes` |

Producer: import (`zef_import_segmentation`) or Segmentation tool. Consumer: mesh labeling, plot, lead-field wrappers.

Inactive rows: `zef_update` removes every `<tag>_*` field for compartments that are off.

## Volume mesh

| Field | Shape / notes |
|-------|----------------|
| `nodes` | `N×3` vertices (project length unit) |
| `tetra` | `M×4` 1-based vertex indices |
| `domain_labels` | `M×1` tissue ids |
| `sigma` | `M×` at least 1; column 1 isotropic S/m; types 6–10 use `(:,3:8)` |
| `brain_ind` / `active_compartment_ind` | Tetra indices that may hold sources |
| `surface_triangles` | Per-compartment FEM boundary faces after postprocess |
| `condition_number` | Tet quality (signed volume convention: see [conventions.md](conventions.md)) |
| `mesh_resolution` | Lattice spacing; default `3` in `zef_init`; examples often use `4.5` |
| `n_sources` | Requested source count (default `10000`); actual count is `size(source_positions,1)` |

Producer: `zef_create_finite_element_mesh`. Lead-field assembly does **not** create the mesh.

## Sensors

| Field | Meaning |
|-------|---------|
| `current_sensors` | Active set tag (default `s`) |
| `sensors` | Working array: `N×3` PEM or `N×6` CEM (see [conventions.md](conventions.md)) |
| `s_points`, `s_name_list`, `s_directions` | Default set (other tags: `<tag>_points`, …) |
| `sensors_attached_volume` | Table from `zef_attach_sensors_volume` — **assign the return value**. PEM: snapped xyz. CEM: index rows `[id n1 n2 n3]`, not metres. EEG/EIT/TES FEM reads this table, not `zef.sensors`. |
| `imaging_method` | Sensor family while processing meshes: `1` EEG, `2` MEG mag, `3` MEG grad |
| `attach_electrodes` | Default `1` (on) |

MEG does not use volume attachment the way EEG/EIT/TES do.

## Lead field

| Field | Meaning |
|-------|---------|
| `L` | Sensors × source DOFs |
| `lead_field_type` | Integer 1–10 (EEG/MEG/EIT/TES × iso/aniso) |
| `source_model` | Default `2` (H(div)); prefer `core.types.ZefSourceModel` |
| `source_direction_mode` | Default `2` (normal) |
| `source_positions` | `n×3` after the lead-field wrap-up, in `location_unit` |
| `source_directions` | Matching orientations |
| `source_ind` | Tetra / lattice indices used as sources |
| `source_interpolation_ind` | Cell; `{1}` required by `zef_processLeadfields` |
| `source_interpolation_on` | If true, `zef_lead_field_matrix` calls interpolation |
| `location_unit` | `1` mm, `2` cm, `3` m |
| `preconditioner` | `1` → CPU incomplete Cholesky (`ichol` nofill), `2` SSOR (default in `zef_init`). **GPU ignores this** and uses Jacobi `1./diag(A)`. |
| `preconditioner_tolerance` | Copied to `lf_param.cholinc_tol`. **Not used** by the current PCG (`ichol` is nofill). Default `0.001`. |
| `solver_tolerance` | PCG relative residual, default `1e-6` (`lf_param.pcg_tol`). Missing-field fallback in the dispatcher is `1e-8`. |
| `lead_field_id` | Incremented when a new `L` is created |
| `non_source_ind` | Tetra excluded from `brain_activity_inds` |

Producer: `zef_lead_field_matrix` and modality wrappers. Consumer: every inverse path.

## Measurements and inverse

| Field | Meaning |
|-------|---------|
| `measurements` | Sensors × time |
| `reconstruction` | Cell of source vectors, one per frame |
| `reconstruction_information` | Small metadata struct (method tag, parameters) |
| `inv_snr` | GUI SNR (dB); class path uses `signal_to_noise_ratio` on the inverter |
| `inv_sampling_frequency` | Default **20000** in `zef_init` (not explained in-tree). Copied onto class inverters by `withPropertiesFromZef`. |
| `inv_time_1`, `inv_time_2`, `inv_time_3` | Start, window, step (seconds). `inv_time_3` default `0.001`. |
| `number_of_frames` | Default `1` |
| `inv_data_mode` | Bundle path forces `'raw'`; `computeInversionWithZI` does not |

Class solvers copy a subset of `inv_*` via `withPropertiesFromZef`. Prefer `MethodParams` on `zef_inverse_run` for cluster-reproducible runs.

## GPU, parallel, logging

| Field | Meaning |
|-------|---------|
| `use_gpu` | Request `gpuDevice(gpu_num)` when a device exists |
| `gpu_num` | Device index |
| `gpu_count` | From `zef_gpu_count` (0 without PCT) |
| `parallel_processes` | Worker count stored on `zef` |
| `use_waitbar` | Progress figure |
| `use_log`, `log_file_name` | Session log under `data/log/` |

## Who owns the struct?

There is no single “owner” type. By convention:

- `zeffiro_interface` / `zef_start` / `zef_init` create and default it
- `zef_update` syncs GUI tables into fields
- `src/mesh` writes mesh arrays
- `src/forward` writes `L` and source geometry
- `src/inverse` and plugins write `reconstruction`
- `zef_save` / `zef_load` persist scientific fields

Scripts that `evalin('base','zef')` assume the GUI session is the copy of record.

## Related

- Field-level detail: [glossary.md](glossary.md) is the short vocabulary; this file is the field list.
- Mesh notes in `documentation/mesh_generation.tex`
- Lead-field notes in `documentation/lead_field_construction.tex` (`location_unit` follows Mesh tool `mm`/`cm`/`m`)
