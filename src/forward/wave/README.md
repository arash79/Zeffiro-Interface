# src/forward/wave

## Purpose of this folder

Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.

## Contents

MATLAB sources:
- `B_T_prod.m` — **B_T_prod**: B T prod.
- `B_prod.m` — **B_prod**: B prod.
- `array_min.m` — **array_min**: Array min.
- `bh_window.m` — **bh_window**: Bh window.
- `boundary_point_source.m` — **boundary_point_source**: Boundary point source.
- `boundary_source.m` — **boundary_source**: Boundary source.
- `calc_cf_and_bw.m` — **calc_cf_and_bw**: Calc cf and bw.
- `free_boundary.m` — **free_boundary**: Free boundary.
- `load_jacobian_data.m` — **load_jacobian_data**: Load jacobian data.
- `load_jacobian_data_complex.m` — **load_jacobian_data_complex**: Load jacobian data complex.
- `mat_vec.m` — **mat_vec**: Mat vec.
- `mh_window.m` — **mh_window**: Mh window.
- `combine_data_complex.m` — **parameters;**: Parameters;.
- `combine_data_sincos.m` — **parameters;**: Parameters;.
- `compute_data.m` — **parameters;**: Parameters;.
- `compute_data_gpu.m` — **parameters;**: Parameters;.
- `create_system.m` — **parameters;**: Parameters;.
- `make_interp_mat.m` — **parameters;**: Parameters;.
- `qam_demod.m` — **qam_demod**: Qam demod.
- `refine_mesh.m` — **refine_mesh**: Refine mesh.
- `save_jacobian_data.m` — **save_jacobian_data**: Save jacobian data.
- `save_jacobian_data_complex.m` — **save_jacobian_data_complex**: Save jacobian data complex.
- `make_born_approximation_amp.m` — **signal_configuration**: Signal configuration.
- `make_born_approximation_qam.m` — **signal_configuration**: Signal configuration.
- `make_difference_data_amp.m` — **signal_configuration**: Signal configuration.
- `make_difference_data_qam.m` — **signal_configuration**: Signal configuration.
- `surface_integral.m` — **surface_integral**: Surface integral.
- `tetra_in_compartment.m` — **tetra_in_compartment**: Tetra in compartment.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

No dedicated menu item in this folder; functionality is reached through parent tools, menus, or `zef_*` orchestration.

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- ``[div_u] = B_T_prod(p_1, p_2, p_3, div_vec, …)` with project root and `src` on the path.`
- ``[p] = B_prod(u, entry_ind, n, t, …)` with project root and `src` on the path.`
- ``[min_ind] = array_min(i, xq, yq, zq, …)` with project root and `src` on the path.`
- ``[[bh_vec, d_bh_vec]] = bh_window(t, T, carrier_cycles_per_pulse_cycle, carrier_mode)` with project root and `src` on the path.`
- ``[[boundary_vec_1, boundary_vec_2]] = boundary_point_source(source_points, orbit_triangles, orbit_nodes)` with project root and `src` on the path.`
- ``[[boundary_vec_1, boundary_vec_2, s_orbit]] = boundary_source(fade_out_param, source_points, orbit_triangles, orbit_nodes)` with project root and `src` on the path.`
- ``[[cf, bw, hf]] = calc_cf_and_bw(t_vec, pulse_vec, varargin)` with project root and `src` on the path.`
- ``[[boundary_triangles, boundary_tetra_ind]] = free_boundary(tetra)` with project root and `src` on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
