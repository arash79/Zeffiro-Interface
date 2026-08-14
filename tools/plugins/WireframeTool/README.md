# Wireframe creator tool

Builds a **printable wireframe surface** from the FEM tetrahedral mesh and a filling vector derived from permittivity `zef.epsilon(:,1)`. GPU-ToRRe-3D microwave geometry, not an EEG tool. Writes `zef.wireframe_triangles`, `zef.wireframe_nodes`, interpolated filling / shape / permittivity vectors.

**Not in the default profile.** Asteroid profiles register **Multi tools → Wireframe creator tool**. Otherwise call `zef_wireframe_creator_start` from MATLAB.

## How to open it

Asteroid profiles: **Multi tools → Wireframe creator tool**, callback `zef_wireframe_creator_start`. Default profile: call that start script. Title: **ZEFFIRO Interface: Wireframe creator tool**.

Need `zef.tetra`, `zef.nodes`, `zef.domain_labels`, `zef.epsilon`.

## Buttons (`ButtonPushedFcn` in `m/zef_wireframe_creator_start.m`)

| Handle | Action |
|--------|--------|
| **Create** | `filling_vec = zef_wireframe_filling_vec(epsilon, relative_permittivity)` then `wireframe(tetra, nodes, domain_labels, filling_vec, printer_resolution, 0, 1, edge_threshold)`; then `zef_wireframe_permittivity_vec` |
| **Plot** | `zef_wireframe_plot(zef.wireframe_triangles, zef.wireframe_nodes)` |

Widgets (ValueChangedFcn → `zef.wireframe_*`): edge threshold (default 1.2), printer resolution (0.15), relative permittivity (6.5), tolerance (0.05), regularization (0.05), n_iter (1000). `wireframe.m` reads `zef.wireframe_n_iter` from base.

## Scripting

```matlab
zef.wireframe_filling_vec = zef_wireframe_filling_vec(zef.epsilon(:,1), zef.wireframe_relative_permittivity);
[zef.wireframe_triangles, zef.wireframe_nodes] = wireframe(zef.tetra, zef.nodes, zef.domain_labels, zef.wireframe_filling_vec, zef.wireframe_printer_resolution, 0, 1, zef.wireframe_edge_threshold);
```
