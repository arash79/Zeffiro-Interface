## Folder purpose

Scripted forward / lead-field demo: build a mesh (via the meshing example) then assemble an EEG (default) lead field into `zef.L`.

## Main contents

| File | Role |
|------|------|
| `lead_field_example.m` | Package function `examples.forward.lead_field_example` |

## Code functionality

Calls `examples.meshing.zef_meshing_example`, then `copy_fields` of `lead_field_kwargs` onto `zef`, `zef_attach_sensors_volume`, `zef_lead_field_matrix`, and `zef_save`. Returns the project struct with `zef.L` populated when the forward run succeeds.

Typical knobs (name-value groups): `use_gpu` (default **true**), `mesh_resolution` (4.5), `n_sources` (1e4), `lead_field_type` (**1–5 only** in this example: EEG / MEG mag / MEG grad / EIT / TES isotropic). Anisotropic types 6–10 are valid in `zef_lead_field_matrix` but `mustBeMember` on this function rejects them. `source_model` (`core.types.ZefSourceModel`, default Hdiv), `source_direction_mode` (default **1** Cartesian; `zef_init` uses **2** Normal). Other example defaults that differ from `zef_init`: `preconditioner` 1 (`ichol` nofill) vs 2 (SSOR), `solver_tolerance` `1e-8` vs `1e-6`.

## Workflow context

Sits after anatomy import / meshing and before inverse or study scripts that need `zef.L`. Default input is `data/segmentations/multicompartment_head_project/import_segmentation.zef` unless you pass `input_project_path`. Writes `data/lead_field_example.mat` by default.

## Usage instructions

```matlab
addpath(fileparts(which('zeffiro_interface')));

zef = examples.forward.lead_field_example();

zef = examples.forward.lead_field_example( ...
    "use_gpu", true, ...
    "mesh_resolution", 4.5, ...
    "n_sources", 1e4, ...
    "lead_field_type", 1, ...
    "source_model", core.types.ZefSourceModel.Hdiv, ...
    "source_direction_mode", 1);
```

## Important notes

Needs the multicompartment segmentation (or an explicit `input_project_path`). This example’s `lead_field_type` argument is **1–5**. For anisotropic 6–10, mesh first then call `zef_lead_field_matrix` yourself. Default `use_gpu` is true — pass `"use_gpu", false` without CUDA.

## Developer guidance

Keep this example thin: mesh via `examples.meshing`, forward via `src/forward` APIs. Prefer kwargs over editing the function body when adding demo options.
