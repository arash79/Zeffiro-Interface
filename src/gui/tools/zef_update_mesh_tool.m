%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% if zef — If zef.
%
% Purpose:
%   If zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.cp_on (read)
%   zef.downsample_surfaces (read, write)
%   zef.enable_str (read, write)
%   zef.forward_simulation_column_selected (read)
%   zef.forward_simulation_script (read, write)
%   zef.forward_simulation_selected (read)
%   zef.forward_simulation_table (read, write)
%   zef.h_checkbox_mesh_smoothing_on (read)
%   zef.h_downsample_surfaces (read)
%   zef.h_edit65 (read)
%   zef.h_edit75 (read)
%   zef.h_edit76 (read)
%   zef.h_edit_cp_a (read)
%   zef.h_edit_cp_b (read)
%   zef.h_edit_cp_c (read)
%   … (27 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header




if zef.mlapp == 1

    zef.mesh_smoothing_on = zef.h_checkbox_mesh_smoothing_on.Value;
    zef.refinement_on = zef.h_refinement_on.Value;
    zef.source_interpolation_on = zef.h_source_interpolation_on.Value;
    zef.downsample_surfaces = zef.h_downsample_surfaces.Value;
    zef.location_unit = zef.h_popupmenu6.Value;
    zef.source_direction_mode = zef.h_popupmenu2.Value;
    zef.mesh_resolution = (zef.h_edit65.Value);
    zef.meshing_accuracy = (zef.h_edit_meshing_accuracy.Value);
    zef.smoothing_strength = (zef.h_smoothing_strength.Value);
    zef.solver_tolerance = (zef.h_edit76.Value);
    zef.n_sources = (zef.h_edit75.Value);
    zef.max_surface_face_count = zef.h_max_surface_face_count.Value ;
    zef.inflate_n_iterations = (zef.h_inflate_n_iterations.Value);
    zef.inflate_strength = zef.h_inflate_strength.Value;
    zef.forward_simulation_script = char(join(string(zef.h_forward_simulation_script.Value'),' '));
    if not(isempty(zef.forward_simulation_selected)) && not(isempty(zef.forward_simulation_script))
        zef.h_forward_simulation_table.Data{zef.forward_simulation_selected(1),zef.forward_simulation_column_selected} = zef.forward_simulation_script;
    end
    zef.forward_simulation_table = zef.h_forward_simulation_table.Data;
else

    if zef.cp_on
        zef.enable_str = 'on';
    else
        zef.enable_str = 'off';
    end;

    set(zef.h_edit_cp_a, 'enable', zef.enable_str);
    set(zef.h_edit_cp_b, 'enable', zef.enable_str);
    set(zef.h_edit_cp_c, 'enable', zef.enable_str);
    set(zef.h_edit_cp_d, 'enable', zef.enable_str);

    set(zef.h_popupmenu1,'value',zef.imaging_method);

end
