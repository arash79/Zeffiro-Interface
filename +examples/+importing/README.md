# +examples/+importing

## Folder purpose

Minimal scripted import of the **bundled multicompartment head** segmentation. Starts Zeffiro in `nodisplay` and loads `import_segmentation.zef`. Does **not** mesh, attach sensors to the volume, or assemble `zef.L`.

## Main contents

| File | Role |
|------|------|
| `zef_import_example.m` | Package function `examples.importing.zef_import_example` |

## Code functionality

```matlab
project_struct = zeffiro_interface( ...
    'start_mode', 'nodisplay', ...
    'import_to_existing_project', ...
    fullfile("data", "segmentations", "multicompartment_head_project", "import_segmentation.zef"));
```

The path is **relative to MATLAB’s current working directory**. Run from the repository root (or pass an absolute path by calling `zeffiro_interface` yourself).

Flag choice: `import_to_existing_project` loads the `.zef` into the session that `zeffiro_interface` just created. It does **not** call `zef_start_new_project`. If `data/default_project.mat` exists and was loaded at start, compartments from that project remain and the `.zef` is imported **on top**. For a guaranteed empty anatomy table, use CLI `'import_to_new_project'` (that path runs `zef_start_new_project` first). The GUI analogue of a clean import is **Import → Import data to a new project**.

`zeffiro_interface` still constructs hidden figures in `nodisplay`.

## Workflow context

First step before `examples.meshing.zef_meshing_example` / `examples.forward.lead_field_example`. Manifest and `.asc` inventory: `data/segmentations/README.md`. Import parsers: `src/io/README.md`.

## Usage instructions

```matlab
cd /path/to/zeffiro_interface
addpath(pwd);   % or already on path via zeffiro_interface
zef = examples.importing.zef_import_example();
% then:
% zef = zef_create_finite_element_mesh(zef);
```

## Important notes

- Relative `data/...` fails if `pwd` is not the project root.
- No automatic Create FEM mesh; `zef.L` is empty afterward.
- Fresh clones often lack `default_project.mat`; when that file is present, prefer `import_to_new_project` for a clean demo.

## Developer guidance

- Keep this example one call with no extra kwargs; put meshing knobs on `examples.meshing.zef_meshing_example`.
- Pitfall: expecting `zef.L` or `zef.reconstruction` after import alone.
