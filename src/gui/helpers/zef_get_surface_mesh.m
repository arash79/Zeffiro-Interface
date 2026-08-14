%ZEF_GET_SURFACE_MESH  Load STL/DAT into the selected compartment surface.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Compartment-table context **Import surface mesh**:
%     Full mesh (STL file) / Points (DAT file) / Triangles (DAT file)
%   The menu sets zef.surface_mesh_type then uigetfile then this script.
%   Writes <current_compartment>_points/_triangles/_submesh_ind and the
%   matching *_original_surface_mesh copies (downsample cache).
%
%   See also zef_get_mesh, zef_add_compartment.

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
