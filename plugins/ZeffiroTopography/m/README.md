## Folder purpose

MATLAB for the Topography tool: sensor-space map on the outer surface. Menu, Start / Apply, and `zef.top_reconstruction`: parent README.

## Main contents

| File | Kind | Role |
|------|------|------|
| `zef_topography.m` | start | INI callback Forward tools → Topography tool |
| `zef_topography_app.m` | widgets | Window title **ZEFFIRO Interface: Topography tool** |
| `zef_init_topography.m` | script | Default `top_*` from inverse `inv_*` |
| `zef_update_topography.m` | script | Widgets → `zef.top_*` and also `inv_*` / frames / `normalize_data` |
| `zef_evaluate_topography.m` | function | Inverse-distance sum → `top_reconstruction` |

## Code functionality

`zef_evaluate_topography` builds an inverse-distance weighted map on `reuna_p{end-1}` (scalp; last entry is usually the bounding box), then L∞-normalizes across frames into `zef.top_reconstruction`. Init sets band/times and `top_regularization_parameter = 5` from inverse defaults.

## Workflow context

Forward tools → Topography tool. Needs surfaces and measurements (or related sensor data) consistent with `top_*` time/band settings.

## Usage instructions

Open from the menu; Start / Apply run update + evaluate as wired in the app. Programmatic:

```matlab
zef_topography
zef_update_topography
zef = zef_evaluate_topography(zef);
```

## Important notes

- Update copies onto both `top_*` and several `inv_*` / global frame fields.
- Scalp index is `reuna_p{end-1}` by convention.

## Developer guidance

Keep evaluation free of App Designer types so scripts can call it. If changing surface index logic, document it next to mesh compartment ordering. Prefer parent README for user-facing Start/Apply behavior.
