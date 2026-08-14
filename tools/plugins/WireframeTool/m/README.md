# Wireframe creator — MATLAB files (`m/`)

GPU-ToRRe microwave **printable wireframe**, not EEG inverse. Asteroid profiles: **Multi tools → Wireframe creator tool**. Default head profile: call `zef_wireframe_creator_start` yourself. What the buttons do and which `zef.wireframe_*` widgets exist: parent [../README.md](../README.md).

Needs `zef.tetra`, `zef.nodes`, `zef.domain_labels`, `zef.epsilon` (permittivity from the parameter profile / NSE-style fields, not `zef.sigma`).

| File | Role |
|------|------|
| `zef_wireframe_creator_start.m` | INI / MATLAB start. **Create** → filling vector then `wireframe(...)`. **Plot** → `zef_wireframe_plot`. |
| `wireframe.m` | Surface extraction from tets + filling. Per-domain branch indexes undeclared `tetrahedra(:,5)` — treat that path as incomplete unless you pass a 5-column tet array. |
| `zef_wireframe_filling_vec.m` / `zef_wireframe_permittivity_vec.m` | Maxwell–Garnett mixing from `epsilon` and relative permittivity. |
| `zef_wireframe_plot.m` | Phong-lit gray surface. Declared arguments are unused; needs `h_t` / `h_a` in the **caller** workspace. |

Layout: [../mlapp/README.md](../mlapp/README.md) (`zef_wireframe_creator_app.mlapp`).
