## Folder purpose

Builds a **printable wireframe surface** from the FEM tetrahedral mesh and a filling vector derived from permittivity `zef.epsilon(:,1)`. GPU-ToRRe-3D microwave geometry, not an EEG tool. Writes `zef.wireframe_triangles`, `zef.wireframe_nodes`, interpolated filling / shape / permittivity vectors.

**Not in the default profile.** Asteroid profiles register **Multi tools → Wireframe creator tool**. Otherwise call `zef_wireframe_creator_start` from MATLAB.

## Main contents

- Start: `m/zef_wireframe_creator_start.m`
- Helpers: `zef_wireframe_filling_vec`, `wireframe`, `zef_wireframe_permittivity_vec`, `zef_wireframe_plot`
- Layout under `mlapp/`

## Code functionality

Need `zef.tetra`, `zef.nodes`, `zef.domain_labels`, `zef.epsilon`.

Buttons (`ButtonPushedFcn` in `m/zef_wireframe_creator_start.m`):

| Handle | Action |
|--------|--------|
| **Create** | `filling_vec = zef_wireframe_filling_vec(epsilon, relative_permittivity)` then `wireframe(tetra, nodes, domain_labels, filling_vec, printer_resolution, 0, 1, edge_threshold)`; then `zef_wireframe_permittivity_vec` |
| **Plot** | `zef_wireframe_plot(zef.wireframe_triangles, zef.wireframe_nodes)` |

Widgets (ValueChangedFcn → `zef.wireframe_*`): edge threshold (default 1.2), printer resolution (0.15), relative permittivity (6.5), tolerance (0.05), regularization (0.05), n_iter (1000). `wireframe.m` reads `zef.wireframe_n_iter` from base.

## Workflow context

Asteroid profiles: **Multi tools → Wireframe creator tool**, callback `zef_wireframe_creator_start`. Default profile: call that start script. Title: **ZEFFIRO Interface: Wireframe creator tool**.

## Usage instructions

```matlab
zef.wireframe_filling_vec = zef_wireframe_filling_vec(zef.epsilon(:,1), zef.wireframe_relative_permittivity);
[zef.wireframe_triangles, zef.wireframe_nodes] = wireframe(zef.tetra, zef.nodes, zef.domain_labels, zef.wireframe_filling_vec, zef.wireframe_printer_resolution, 0, 1, zef.wireframe_edge_threshold);
```

1. Ensure mesh, domain labels, and permittivity are set.
2. Open Wireframe creator tool (asteroid menu) or call `zef_wireframe_creator_start`.
3. Create, then Plot.

## Important notes

- Not registered on the default profile menu.
- Microwave / GPU-ToRRe-3D geometry, not EEG inverse.
- `wireframe.m` reads `zef.wireframe_n_iter` from the base workspace.

## Developer guidance

Preserve callback `zef_wireframe_creator_start` and outputs `zef.wireframe_triangles` / `zef.wireframe_nodes`. Keep widget defaults documented with `zef.wireframe_*` fields.
