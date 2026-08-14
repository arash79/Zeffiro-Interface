# Meshing examples

How to build a FEM mesh from the bundled multicompartment segmentation. Project root on the path; `src` is added by `zeffiro_interface`.

```matlab
addpath(fileparts(which('zeffiro_interface')));  % or addpath(projectRoot)

% Default head project (must exist):
%   data/segmentations/multicompartment_head_project/import_segmentation.zef
zef = examples.meshing.zef_meshing_example();
% writes data/meshing_example.mat  (kwargs.output_project_dir / output_project_file)

% Optional kwargs (see arguments block): start_mode, input_project_path,
% mesh_resolution (default 4.5), refinement_surface_compartments, use_gpu, ...
zef = examples.meshing.zef_meshing_example("mesh_resolution", 3, "use_gpu", false);
```

What it does: `zeffiro_interface(..., 'import_to_existing_project', input_project_path)` → `copy_fields` of meshing kwargs onto `zef` → `zef_create_finite_element_mesh` → `zef_save`.

## Thalamus refinement variant

```matlab
zef = examples.meshing.zef_meshing_example_thalamus_refinement();
% saves data/example_project.mat
```

**Different import path:** `scripts/scripts_for_importing/multicompartment_head_project/import_segmentation.zef` (not the `data/segmentations/...` file). Sets surface refinement on scalp/skull (18, 17) and volume refinement on compartment 7 (thalamus), `mesh_resolution = 3`. No kwargs.

If that `scripts/...` path is missing, the call fails at import. Prefer `zef_meshing_example` with an explicit `input_project_path` unless you keep the scripts tree.
