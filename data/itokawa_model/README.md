# data/itokawa_model

## Folder purpose

Surface meshes for the **Itokawa asteroid** demo used with asteroid gravity / radar profiles and example projects. Provides exterior and interior compartment STLs for segmentation / meshing workflows.

## Main contents

| File | Role |
|------|------|
| `itokawa_exterior.stl` | Outer surface (~0.6 MB) |
| `itokawa_exterior_highres.stl` | High-resolution exterior (~9.8 MB) |
| `mantle.stl` | Mantle compartment surface |
| `void.stl` | Interior void surface |
| `README.txt` | Short legacy asset note |
| `README.md` | This documentation |

## Code functionality

Binary/ASCII STL geometry only — no MATLAB entry points in this folder. Import via segmentation / surface mesh tools or load a prebuilt project from `data/example_projects` (`asteroid_gravity_project.mat`, `asteroid_radar_project.mat`).

## Workflow context

```
STL surfaces (this folder)
    → segmentation / mesh tool (src/gui, src/mesh)
    → profile/asteroid_gravity or asteroid_radar
    → forward / inverse demos (+examples, plugins)
```

Use `scripts/validate_stl_manifold.py` to QA manifoldness before meshing.

## Usage instructions

```matlab
% Prefer opening the shipped project:
proj = fullfile(zef.program_path, 'data', 'example_projects', ...
    'asteroid_gravity_project.mat');
zef = zeffiro_interface('open_project', proj);

% Or import STL via Segmentation tool → surface mesh import
```

CLI manifold check:

```bash
python3 scripts/validate_stl_manifold.py data/itokawa_model/itokawa_exterior.stl
```

## Important notes

- Units and scale must match asteroid profile mesh settings (do not mix with head-mm assumptions blindly).
- Highres exterior is large — prefer the standard exterior for routine tests.
- `README.txt` may be terse; trust this README + profile docs for workflow.

## Developer guidance

- When replacing meshes, keep filenames stable or update example projects and docs together.
- Store raw authoring files elsewhere if they are huge; ship only what demos need.
- Pitfall: meshing highres exterior on a laptop without adjusting resolution parameters.
