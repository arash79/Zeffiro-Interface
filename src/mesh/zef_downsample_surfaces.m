function zef = zef_downsample_surfaces(zef)
%ZEF_DOWNSAMPLE_SURFACES  Resample, smooth, and optionally inflate compartment surfaces.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Before a tetrahedral mesh is built, each active compartment surface
%   (<tag>_on) is reduced or refined toward a target triangle count,
%   then lightly smoothed. Source compartments can also be inflated so
%   that later labeling and source placement sit slightly inside the
%   tissue rather than exactly on the imported boundary.
%
%   The first call caches the original points/triangles/submesh index
%   under <tag>_*_original_surface_mesh so later resampling always
%   starts from the imported geometry rather than compounding
%   reducepatch. Target face count is
%   zef.max_surface_face_count * relative_resolution(compartment),
%   where relative_resolution comes from zef_find_relative_resolution
%   (refinement flags raise the budget by 4^n).
%
%   GUI
%     Mesh tool window "ZEFFIRO Interface: Mesh tool":
%       checkbox "Resample surf." (h_downsample_surfaces) stores the flag
%       zef.downsample_surfaces. The button "Resample surfaces"
%       (h_surface_downsampling) runs zef_surface_downsampling, which
%       calls this function then zef_process_meshes and interpolation.
%     "Create FEM mesh" (h_pushbutton21) runs zef_create_finite_element_mesh,
%     which calls this function first when zef.downsample_surfaces == 1.
%
%   Scripting
%     zef.downsample_surfaces = 1;
%     zef.max_surface_face_count = 1000;   % Mesh tool "Surface triangles max."
%     zef = zef_downsample_surfaces(zef);
%
%   zef = zef_downsample_surfaces(zef)
%
%   Input / output
%     zef  - session struct. If omitted, read from the base workspace.
%            If nargout is 0, the result is assigned back to base.
%
%   Fields read
%     compartment_tags, <tag>_on, <tag>_points, <tag>_triangles,
%     <tag>_submesh_ind, <tag>_sources, <tag>_scaling, max_surface_face_count,
%     bypass_inflate, inflate_n_iterations / inflate_strength (via inflate).
%
%   Fields written
%     <tag>_points, <tag>_triangles, <tag>_submesh_ind, <tag>_points_inf,
%     and the *_original_surface_mesh cache on first use.
%
%   See also zef_set_surface_resolution, zef_smooth_surface, zef_inflate_surface,
%            zef_create_finite_element_mesh, zef_surface_downsampling.

if nargin == 0
    zef = evalin('base','zef');
end

zef.h = zef_waitbar(0,1,'Resampling surfaces.');
zef.temp_time = now;
relative_resolution_vec = zef_find_relative_resolution(zef);
zef.number_of_compartments = length(zef.compartment_tags);
active_compartment_ind = 0;

for zef_k = 1 : zef.number_of_compartments
    zef.temp_var_0 = zef.compartment_tags{zef_k};

    if zef.([zef.temp_var_0 '_on'])

        zef.temp_patch_data.scaling = eval(['zef.' zef.temp_var_0 '_scaling;']);

        if eval(['zef.' zef.temp_var_0 '_on'])
            active_compartment_ind = active_compartment_ind + 1;
            % Prefer the cached original surface so repeated resampling is
            % not applied on top of an already-decimated mesh.
            if eval(['isfield(zef,"' zef.temp_var_0 '_points_original_surface_mesh")'])
                if eval(['not(isempty(zef.' zef.temp_var_0 '_points_original_surface_mesh))'])
                    zef.temp_patch_data.vertices_all = eval(['zef.' zef.temp_var_0 '_points_original_surface_mesh;']);
                    zef.temp_patch_data.faces_all = eval(['zef.' zef.temp_var_0 '_triangles_original_surface_mesh;']);
                    zef.temp_patch_data.submesh_ind = eval(['zef.' zef.temp_var_0 '_submesh_ind_original_surface_mesh;']);
                else
                    zef.temp_patch_data.vertices_all = eval(['zef.' zef.temp_var_0 '_points;']);
                    zef.temp_patch_data.faces_all = eval(['zef.' zef.temp_var_0 '_triangles;']);
                    zef.temp_patch_data.submesh_ind = eval(['zef.' zef.temp_var_0 '_submesh_ind;']);
                    eval(['zef.' zef.temp_var_0 '_points_original_surface_mesh = zef.' zef.temp_var_0 '_points;']);
                    eval(['zef.' zef.temp_var_0 '_triangles_original_surface_mesh = zef.' zef.temp_var_0 '_triangles;']);
                    eval(['zef.' zef.temp_var_0 '_submesh_ind_original_surface_mesh = zef.' zef.temp_var_0 '_submesh_ind;']);
                end
            else
                zef.temp_patch_data.vertices_all = eval(['zef.' zef.temp_var_0 '_points;']);
                zef.temp_patch_data.faces_all = eval(['zef.' zef.temp_var_0 '_triangles;']);
                zef.temp_patch_data.submesh_ind = eval(['zef.' zef.temp_var_0 '_submesh_ind;']);
                eval(['zef.' zef.temp_var_0 '_points_original_surface_mesh = zef.' zef.temp_var_0 '_points;']);
                eval(['zef.' zef.temp_var_0 '_triangles_original_surface_mesh = zef.' zef.temp_var_0 '_triangles;']);
                eval(['zef.' zef.temp_var_0 '_submesh_ind_original_surface_mesh = zef.' zef.temp_var_0 '_submesh_ind;']);

            end

            eval(['zef.' zef.temp_var_0 '_points_inf = [];']);
            eval(['zef.' zef.temp_var_0 '_points = [];']);
            eval(['zef.' zef.temp_var_0 '_triangles = [];']);

            if eval(['not(isempty(zef.' zef.temp_var_0 '_submesh_ind));'])
                % submesh_ind holds cumulative last-face indices. Each
                % submesh is resampled independently, then concatenated
                % with face indices offset by the running vertex count.
                zef_i = 0;
                for zef_j = 1 : length(zef.temp_patch_data.submesh_ind)
                    zef_i = zef_i + 1;
                    zef.temp_patch_data.faces = zef.temp_patch_data.faces_all(zef_i : zef.temp_patch_data.submesh_ind(zef_j),:);
                    zef.temp_patch_data.vertice_ind_aux = zeros(size(zef.temp_patch_data.vertices_all,1),1);
                    zef.temp_patch_data.unique_faces_ind = unique(zef.temp_patch_data.faces);
                    zef.temp_patch_data.vertice_ind_aux(zef.temp_patch_data.unique_faces_ind) = [1:length(zef.temp_patch_data.unique_faces_ind)];
                    zef.temp_patch_data.faces = zef.temp_patch_data.vertice_ind_aux(zef.temp_patch_data.faces);
                    zef.temp_patch_data.vertices = zef.temp_patch_data.vertices_all(zef.temp_patch_data.unique_faces_ind,:);
                    zef.temp_patch_data_aux = zef_set_surface_resolution(zef,zef.temp_patch_data,zef.max_surface_face_count*relative_resolution_vec(active_compartment_ind));
                    zef.temp_patch_data_aux.vertices = zef_smooth_surface(zef.temp_patch_data_aux.vertices,zef.temp_patch_data_aux.faces,1e-2,1);
                    % Source flag is treated as boolean here (any nonzero).
                    if eval(['zef.' zef.temp_var_0 '_sources'])
                        if isempty(zef.temp_patch_data_aux.vertices) || zef.bypass_inflate
                            zef.temp_patch_data_aux.vertices_inflated = [];
                        else
                            [zef.temp_patch_data_aux.vertices_inflated] = zef_inflate_surface(zef,zef.temp_patch_data_aux.vertices,zef.temp_patch_data_aux.faces);
                        end
                        eval(['zef.' zef.temp_var_0 '_points_inf = [zef.' zef.temp_var_0 '_points_inf ;  zef.temp_patch_data_aux.vertices_inflated];']);
                    end
                    eval(['zef.' zef.temp_var_0 '_triangles = [zef.' zef.temp_var_0 '_triangles; zef.temp_patch_data_aux.faces+size(zef.' zef.temp_var_0 '_points,1)];']);
                    eval(['zef.' zef.temp_var_0 '_points = [zef.' zef.temp_var_0 '_points ;  zef.temp_patch_data_aux.vertices];']);
                    zef_i = zef.temp_patch_data.submesh_ind(zef_j);
                    eval(['zef.' zef.temp_var_0 '_submesh_ind(' int2str(zef_j) ') = size(zef.' zef.temp_var_0 '_triangles,1);']);
                end
            else
                zef.temp_patch_data.faces = zef.temp_patch_data.faces_all;
                zef.temp_patch_data.vertices = zef.temp_patch_data.vertices_all;
                zef.temp_patch_data_aux = zef_set_surface_resolution(zef,zef.temp_patch_data,zef.max_surface_face_count*relative_resolution_vec(active_compartment_ind));
                zef.temp_patch_data_aux.vertices = zef_smooth_surface(zef.temp_patch_data_aux.vertices,zef.temp_patch_data_aux.faces,1e-2,1);
                % No-submesh path requires sources > 0 (PML uses -1).
                if eval(['zef.' zef.temp_var_0 '_sources']) > 0
                    zef.temp_patch_data_aux.vertices_inflated = zef_inflate_surface(zef,zef.temp_patch_data_aux.vertices,zef.temp_patch_data_aux.faces);
                    eval(['zef.' zef.temp_var_0 '_points_inf = [zef.' zef.temp_var_0 '_points_inf ;  zef.temp_patch_data_aux.vertices_inflated];']);
                end
                eval(['zef.' zef.temp_var_0 '_points = [zef.' zef.temp_var_0 '_points ;  zef.temp_patch_data_aux.vertices];']);
                eval(['zef.' zef.temp_var_0 '_triangles = [zef.' zef.temp_var_0 '_triangles; zef.temp_patch_data_aux.faces];']);
            end
        end

        zef_waitbar(zef_k,zef.number_of_compartments,zef.h,['Resampling surfaces. Ready approx.: ' datestr(now + (zef.number_of_compartments-zef_k)*(now-zef.temp_time)/zef_k) '.'] );

    end
end

zef_close_waitbar(zef.h);

if isfield(zef,'temp_patch_data')
    zef = rmfield(zef,'temp_patch_data');
end

if isfield(zef,'temp_patch_data_aux')
    zef = rmfield(zef,'temp_patch_data_aux');
end

if isfield(zef,'temp_var_0')
    zef = rmfield(zef,'temp_var_0');
end

if isfield(zef,'temp_time')
    zef = rmfield(zef,'temp_time');
end

clear zef_i zef_j zef_k

if nargout == 0
    assignin('base','zef',zef);
end

end
