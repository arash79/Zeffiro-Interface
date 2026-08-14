# `data/example_projects`

Saved Zeffiro `.mat` sessions you can open instead of importing surfaces from scratch. Large binaries may be gitignored or LFS — check the clone before assuming they exist.

| File | Matches profile / data |
|------|------------------------|
| `multicompartment_head_project.mat` | Default head; surfaces also under `data/segmentations/multicompartment_head_project/` |
| `asteroid_gravity_project.mat` | `profile/asteroid_gravity`; Itokawa STLs in `data/itokawa_model/` |
| `asteroid_radar_project.mat` | `profile/asteroid_radar`; three-layer Itokawa STLs |
| `ary_sphere_project.mat` | Synthetic sphere demo |

```matlab
zef = zeffiro_interface('open_project', ...
    fullfile(projectRoot,'data','example_projects','multicompartment_head_project.mat'));
```

`open_project` is one path. If you pass only a filename, `zeffiro_interface` looks in `data/`, not in this folder.

These are session snapshots (`zef` fields), not source. Parent: [`data/README.md`](../README.md).
