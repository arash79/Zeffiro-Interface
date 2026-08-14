# Forward / lead-field example

Builds a mesh (by calling `examples.meshing.zef_meshing_example`) then an EEG (default) lead field.

```matlab
addpath(fileparts(which('zeffiro_interface')));

% Full pipeline; writes data/lead_field_example.mat
zef = examples.forward.lead_field_example();

% Typical knobs (three argument groups):
zef = examples.forward.lead_field_example( ...
    "use_gpu", true, ...
    "mesh_resolution", 4.5, ...
    "n_sources", 1e4, ...
    "lead_field_type", 1, ...          % 1 EEG … 5 tES; 6–10 anisotropic (zef_lead_field_matrix)
    "source_model", core.types.ZefSourceModel.Hdiv, ...
    "source_direction_mode", 1);
```

Needs `data/segmentations/multicompartment_head_project/import_segmentation.zef` unless you pass `input_project_path`. After meshing: `copy_fields` of `lead_field_kwargs` → `zef_attach_sensors_volume` → `zef_lead_field_matrix` → `zef_save`. Returns the project struct with `zef.L` populated when the forward run succeeds.
