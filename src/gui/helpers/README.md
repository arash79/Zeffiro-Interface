# src/gui/helpers

## Purpose of this folder

Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.

## Contents

MATLAB sources:
- `zef_snapshot_movie.m` — **[zef.file zef.file_path zef.file_index] = uiputfile({'*.jpg';'*.tif';'*.png';'*.avi'},'Save visualization as...',zef**: [zef.file zef.file path zef.file index] = uiputfile({'*.jpg';'*.tif';'*.png';'*.avi'},'Save visualization as...',zef.
- `zef_get_data_compartment_table.m` — **eval(['zef.' zef.compartment_tags{zef_j}, '_on = ' num2str(double(zef**: Eval(['zef.' zef.compartment tags{zef j}, ' on = ' num2str(double(zef.
- `zef_exclude_load_fields.m` — **exclude_fields**: Exclude fields.
- `zef_fig_num.m` — **fig_num**: Fig num.
- `zef_reset_parameter_profile.m` — **for zef_i = 1 : size(zef**: For zef i = 1 : size(zef.
- `zef_decompose_dof_space.m` — **function [ ...**: Function [ ....
- `zef_hdiv_interpolation.m` — **function [G, interpolation_positions] = zef_hdiv_interpolation( ...**: Function [G, interpolation positions] = zef hdiv interpolation( ....
- `zef_st_venant_interpolation.m` — **function [G, interpolation_positions] = zef_st_venant_interpolation( ...**: Function [G, interpolation positions] = zef st venant interpolation( ....
- `zef_whitney_interpolation.m` — **function [G, interpolation_positions] = zef_whitney_interpolation( ...**: Function [G, interpolation positions] = zef whitney interpolation( ....
- `zef_transfer_matrix.m` — **function [T, Schur_complement, A] = zef_transfer_matrix(zef, ...**: Function [T, Schur complement, A] = zef transfer matrix(zef, ....
- `zef_callbackstop.m` — **function []=zef_callbackstop(src,~)**: GUI callback for function []=zefstop(src,~) actions.
- `zef_slidding_callback.m` — **function []=zef_slidding_callback**: GUI callback for function []=slidding actions.
- `zef_reset_color_sliders.m` — **function zef_reset_color_sliders**: Function zef reset color sliders.
- `zef_refinement_step.m` — **if ismember(refinement_flag, [1, 3])**: If ismember(refinement flag, [1, 3]).
- `zef_inv_import.m` — **if not(isempty(zef.save_file_path)) & not(zef**: If not(isempty(zef.save file path)) & not(zef.
- `zef_merge_lead_field.m` — **if not(isempty(zef.save_file_path)) & not(zef**: If not(isempty(zef.save file path)) & not(zef.
- `zef_get_sensor_directions.m` — **if not(isequal(zef**: If not(isequal(zef.
- `zef_get_sensor_points.m` — **if not(isequal(zef**: If not(isequal(zef.
- `zef_get_surface_mesh.m` — **if not(isequal(zef**: If not(isequal(zef.
- `zef_smoothing_step.m` — **if zef**: If zef.
- `zef_replace_project_fields.m` — **if zef.current_version <= 2**: If zef.current version <= 2.
- `zef_nearest_points.m` — **nearest_list**: Nearest list.
- `zef_smooth_electrodes.m` — **nodes_old = zef**: Nodes old = zef.
- `zef_mpo_system.m` — **out_coeff_sys**: Out coeff sys.
- `zef_pbo_system.m` — **out_coeff_sys**: Out coeff sys.
- `zef_segmentation_counter_step.m` — **pml_ind_aux = [];**: Pml ind aux = [];.
- `zef_reopen_figure.m` — **set(gcbo,'Tag','');**: Set(gcbo,'Tag','');.
- `zef_size_change.m` — **set(gcf,'AutoResizeChildren','off');**: Set(gcf,'Auto Resize Children','off');.
- `zef_L2_norm.m` — **zef_L2_norm**: Zef L2 norm.
- `zef_adjacency_matrix.m` — **zef_adjacency_matrix**: Zef adjacency matrix.
- `zef_tile_windows.m` — **zef_arrange_windows**: Zef arrange windows.
- `zef_assign_data.m` — **zef_assign_data**: Zef assign data.
- `zef_axes_popup.m` — **zef_axes_popup**: Zef axes popup.
- `zef_blue_brain_1_colormap.m` — **zef_blue_brain_1_colormap**: Zef blue brain 1 colormap.
- `zef_blue_brain_2_colormap.m` — **zef_blue_brain_2_colormap**: Zef blue brain 2 colormap.
- `zef_blue_brain_3_colormap.m` — **zef_blue_brain_3_colormap**: Zef blue brain 3 colormap.
- `zef_brightness_and_contrast.m` — **zef_brighness_and_contrast**: Zef brighness and contrast.
- `zef_cem_electrode.m` — **zef_cem_electrode**: Zef cem electrode.
- `zef_change_size_function.m` — **zef_change_size_function**: Zef change size function.
- `zef_choose_domain_labels.m` — **zef_choose_domain_labels**: Zef choose domain labels.
- `zef_closereq.m` — **zef_closereq**: Zef closereq.
- `zef_colormap.m` — **zef_colormap**: Zef colormap.
- `zef_compute_eit_data.m` — **zef_compute_eit_data**: Zef compute eit data.
- `zef_condition_number.m` — **zef_condition_number**: Zef condition number.
- `zef_contrast_1_colormap.m` — **zef_contrast_1_colormap**: Zef contrast 1 colormap.
- `zef_contrast_2_colormap.m` — **zef_contrast_2_colormap**: Zef contrast 2 colormap.
- `zef_contrast_3_colormap.m` — **zef_contrast_3_colormap**: Zef contrast 3 colormap.
- `zef_contrast_4_colormap.m` — **zef_contrast_4_colormap**: Zef contrast 4 colormap.
- `zef_contrast_5_colormap.m` — **zef_contrast_4_colormap**: Zef contrast 4 colormap.
- `zef_remove_object_fields.m` — **zef_data**: Zef data.
- … (39 more `.m` files in this folder)

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

- **zef_data = zef_additional_options_app;**: GUI callback or dialog (`zef_data = zef_additional_options_app;`).
- **function []=zef_callbackstop(src,~)**: GUI callback or dialog (`function []=zef_callbackstop(src,~)`).
- **zef_import**: GUI callback or dialog (`zef_import`).
- **if not(isempty(zef.save_file_path)) & not(zef**: GUI callback or dialog (`if not(isempty(zef.save_file_path)) & not(zef`).
- **if not(isempty(zef.save_file_path)) & not(zef**: GUI callback or dialog (`if not(isempty(zef.save_file_path)) & not(zef`).
- **function []=zef_slidding_callback**: GUI callback or dialog (`function []=zef_slidding_callback`).

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `[zef.file zef.file_path zef.file_index] = uiputfile({'*.jpg';'*.tif';'*.png';'*.avi'},'Save visualization as...',zef` from MATLAB with the project root on the path.`
- `Call `eval(['zef.' zef.compartment_tags{zef_j}, '_on = ' num2str(double(zef` from MATLAB with the project root on the path.`
- `Call `exclude_fields` from MATLAB with the project root on the path.`
- `Call `fig_num` from MATLAB with the project root on the path.`
- `Call `for zef_i = 1 : size(zef` from MATLAB with the project root on the path.`
- ``function [ ...(in_center_points, in_lattice_res_x, in_lattice_res_y, in_lattice_res_z)` with project root and `src` on the path.`
- ``function [G, interpolation_positions] = zef_hdiv_interpolation( ...(p_nodes, p_tetrahedra, p_brain_inds, p_intended_source_inds, …)` with project root and `src` on the path.`
- ``function [G, interpolation_positions] = zef_st_venant_interpolation( ...(p_nodes, p_tetrahedra, p_brain_inds, p_intended_source_inds, …)` with project root and `src` on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Populated `zef` struct (from `zeffiro_interface` or `zef_load`).
- Package namespaces `core.*`, `inverse.*`, `utilities.*` via project-root `addpath`.
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
