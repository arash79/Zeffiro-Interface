## Folder purpose

Examples that build a FEM mesh from the bundled multicompartment segmentation. Project root on the path; `src` is added by `zeffiro_interface`.

## Main contents

| File | Role |
|------|------|
| `zef_meshing_example.m` | Default mesh demo with kwargs |
| `zef_meshing_example_thalamus_refinement.m` | Thalamus / surface refinement variant |

## Code functionality

`zef_meshing_example`: `zeffiro_interface(..., 'import_to_existing_project', input_project_path)` → `copy_fields` of meshing kwargs onto `zef` → `zef_create_finite_element_mesh` → `zef_save`. Optional kwargs include `start_mode`, `input_project_path`, `mesh_resolution` (default 4.5), `refinement_surface_compartments`, `use_gpu`. Writes `data/meshing_example.mat` by default (`output_project_dir` / `output_project_file`).

`zef_meshing_example_thalamus_refinement`: different import path (`scripts/scripts_for_importing/multicompartment_head_project/import_segmentation.zef`), surface refinement on scalp/skull (18, 17), volume refinement on compartment 7 (thalamus), `mesh_resolution = 3`. Saves `data/example_project.mat`. No kwargs.

## Workflow context

After segmentation import, before lead-field assembly (`examples.forward`) or inverse. Default head project: `data/segmentations/multicompartment_head_project/import_segmentation.zef`.

## Usage instructions

```matlab
addpath(fileparts(which('zeffiro_interface')));

zef = examples.meshing.zef_meshing_example();
zef = examples.meshing.zef_meshing_example("mesh_resolution", 3, "use_gpu", false);

zef = examples.meshing.zef_meshing_example_thalamus_refinement();
```

## Important notes

The thalamus variant uses `scripts/...` (not `data/segmentations/...`). If that scripts tree is missing, import fails — prefer `zef_meshing_example` with an explicit `input_project_path`.

## Developer guidance

Keep default and refinement demos separate. New mesh options should go on the kwargs block of `zef_meshing_example`, not hardcoded into callers of `examples.forward`.
