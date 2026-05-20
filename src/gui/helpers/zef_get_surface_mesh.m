% --- Zeffiro documentation header ---
% if not(isequal(zef — If not(isequal(zef.
%
% Purpose:
%   If not(isequal(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.aux_points (read)
%   zef.aux_submesh_ind (read)
%   zef.aux_triangles (read)
%   zef.current_compartment (read)
%   zef.file (read)
%   zef.file_path (read)
%   zef.surface_mesh_type (read)
%
% Calls (project):
%   zef_get_mesh
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if not(isequal(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

if not(isequal(zef.file,0))
    [zef.aux_points,zef.aux_triangles,zef.aux_submesh_ind] = zef_get_mesh(zef,[zef.file_path zef.file],zef.current_compartment,zef.surface_mesh_type,'full');
    eval(['zef.' zef.current_compartment '_points = zef.aux_points;']);
    eval(['zef.' zef.current_compartment '_triangles = zef.aux_triangles;']);
    eval(['zef.' zef.current_compartment '_submesh_ind = zef.aux_submesh_ind;']);

    eval(['zef.' zef.current_compartment '_points_original_surface_mesh = zef.aux_points;']);
    eval(['zef.' zef.current_compartment '_triangles_original_surface_mesh = zef.aux_triangles;']);
    eval(['zef.' zef.current_compartment '_submesh_ind_original_surface_mesh = zef.aux_submesh_ind;']);

    zef = rmfield(zef,{'aux_points','aux_triangles','aux_submesh_ind'});
end;
