# ZeffiroTopography — leftover GUIDE layout (`fig/`)

## Folder purpose

Holds the archived GUIDE resource **`zeffiro_interface_topography.fig`** for the **Topography tool** plugin. The live Forward-tools path does **not** load this file: menu callback **`zef_topography`** builds the window in MATLAB via **`zef_topography_app`**. The parent plugin maps filtered sensor time series onto the outer surface mesh with a regularized inverse-distance sum; it does **not** invert a lead field.

## Main contents

| File | Role |
|------|------|
| `zeffiro_interface_topography.fig` | Leftover GUIDE figure (not opened by current start) |
| `README.md` | This documentation |

Live code under `../m/`: `zef_topography.m` (entry), `zef_topography_app.m` (programmatic UI), `zef_init_topography` / `zef_update_topography`, `zef_evaluate_topography` (algorithm).

## Code functionality

Live Start writes **`zef.top_reconstruction`** (vector or cell of frames) via `zef_evaluate_topography`. Window title: **ZEFFIRO Interface: Topography tool**. Apply copies topography widgets into `zef.top_*` and also into shared `zef.inv_*` time/band / `number_of_frames` / `normalize_data` fields. Mesh visualization type **5** plots `top_reconstruction`. Surface targets are `zef.reuna_p{end-1}` / `zef.reuna_t{end-1}`.

## Workflow context

Parent plugin: `tools/plugins/ZeffiroTopography`. Default profile: Forward tools → **Topography tool**, callback `zef_topography`. Needs `zef.sensors`, surface meshes (`zef.reuna_*`), and `zef.measurements`. Time/band widgets seed from inverse settings (`zef.inv_*`) on init.

## Usage instructions

Do **not** rely on opening `zeffiro_interface_topography.fig` for normal use. Launch:

```matlab
zef = zef_topography(zef);   % → zef_topography_app + zef_init_topography
% Start button: zef.top_reconstruction = zef_evaluate_topography(zef);
```

Or use Forward tools → Topography tool, Apply, then Start; view with mesh visualization type 5.

## Important notes

- Real figure file in this folder: **`zeffiro_interface_topography.fig`** (leftover).
- Start script users should know: **`zef_topography`** (opens live UI through `zef_topography_app`, not this `.fig`).
- Parent plugin purpose: sensor→surface topography field in `zef.top_reconstruction` (not lead-field inverse).
- Apply mutates shared inverse time/band fields — be careful when both inverse and topography tools are open.
- Deleting the leftover `.fig` would not break the live menu path.

## Developer guidance

- Preserve callback `zef_topography`, output `zef.top_reconstruction`, and mesh visualization type 5 contract.
- Keep the algorithm in `zef_evaluate_topography`; replace `zef_topography_app` if migrating to App Designer — do not revive GUIDE edits to this `.fig`.
- Document any change to which surface index (`end-1`) is treated as “outer”.
