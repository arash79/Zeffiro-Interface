# data/example_projects

## Folder purpose

Shipped **demo `.mat` projects** for quick GUI / script sessions. Each file is a serialized Zeffiro session (mesh, sensors, parameters, and often a lead field) suitable for `open_project` without rebuilding geometry from scratch.

## Main contents

| File | Approx. size | Intended profile / use |
|------|--------------|-------------------------|
| `multicompartment_head_project.mat` | ~21 MB | Default multicompartment head demo |
| `asteroid_gravity_project.mat` | ~16 MB | Asteroid gravity profile demo |
| `asteroid_radar_project.mat` | ~16 MB | Asteroid radar profile demo |
| `ary_sphere_project.mat` | ~23 MB | Synthetic sphere / method tests |

Exact contents vary with the saved session (compartments, `L`, measurements, reconstructions).

## Code functionality

These are MATLAB `-v7.3`/`-v7` MAT files consumed by Zeffiro project open logic under `src/io`. No executable code in this folder.

## Workflow context

```
zeffiro_interface('open_project', fullfile(...,'data','example_projects','….mat'))
    → src/io project load
    → profile menus from profile/*/zeffiro_plugins.ini
```

Related assets: `data/itokawa_model` (STL sources for asteroid demos), `data/segmentations`, `profile/*`.

## Usage instructions

```matlab
proj = fullfile(zef.program_path, 'data', 'example_projects', ...
    'multicompartment_head_project.mat');
zef = zeffiro_interface('open_project', proj);
```

Or open from the GUI **Project → Open** and browse to this folder.

**Important:** bare filenames passed to some helpers resolve under `data/`, not automatically under `data/example_projects/` — pass a full path.

## Important notes

- Large binaries — avoid re-saving casually in git without need.
- Projects may assume a matching profile (`multicompartment_head`, `asteroid_gravity`, …).
- May contain lead fields computed with a specific MATLAB/toolbox revision; recompute if solvers misbehave.

## Developer guidance

- When updating a demo, document the mesh resolution, sensor set, and Zeffiro version in the commit message.
- Prefer regenerating from scripts under `+examples` when possible so demos stay reproducible.
- Pitfall: opening an asteroid project while the active profile INI still points at head-only plugins.
