# WireframeTool — App Designer layouts

## Folder purpose

App Designer UI for the **Wireframe creator tool**: build a printable wireframe surface from the FEM tetrahedral mesh and a permittivity-based filling vector (GPU-ToRRe-3D microwave geometry, not EEG).

## Main contents

| File | Role |
|------|------|
| `zef_wireframe_creator_app.mlapp` | Wireframe creator (Create / Plot, edge threshold, printer resolution, relative permittivity, tolerance, regularization, n_iter) |
| `README.md` | This documentation |

MATLAB logic: `plugins/WireframeTool/m/` (`zef_wireframe_creator_start`, `zef_wireframe_filling_vec`, `wireframe`, `zef_wireframe_permittivity_vec`, `zef_wireframe_plot`).

## Code functionality

`zef_wireframe_creator_start` opens this app and wires **Create** → filling vector + `wireframe(...)` + permittivity vector, and **Plot** → `zef_wireframe_plot(zef.wireframe_triangles, zef.wireframe_nodes)`. ValueChangedFcn widgets write `zef.wireframe_*` fields. Needs `zef.tetra`, `zef.nodes`, `zef.domain_labels`, `zef.epsilon`.

## Workflow context

Asteroid profiles: **Multi tools → Wireframe creator tool** (`zef_wireframe_creator_start`). Not in the default profile — call the start script from MATLAB. Title: **ZEFFIRO Interface: Wireframe creator tool**.

## Usage instructions

```matlab
zef_wireframe_creator_start;   % opens zef_wireframe_creator_app.mlapp
```

1. Ensure mesh, domain labels, and permittivity are set.
2. Open Wireframe creator (asteroid menu) or call the start script.
3. Create, then Plot.

Edit UI only in App Designer.

## Important notes

- Microwave / GPU-ToRRe-3D geometry — not an EEG inverse tool.
- `wireframe.m` reads `zef.wireframe_n_iter` from the base workspace.
- Outputs: `zef.wireframe_triangles`, `zef.wireframe_nodes`.

## Developer guidance

- Preserve callback `zef_wireframe_creator_start` and `zef.wireframe_*` field names.
- Keep Create / Plot button Tags aligned with the start script.
- Document widget defaults in the parent plugin README when they change.
