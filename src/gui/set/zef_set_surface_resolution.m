function  patch_data = zef_set_surface_resolution(zef,patch_data,surface_resolution)
% --- Zeffiro documentation header ---
% zef_set_surface_resolution — Zef set surface resolution.
%
% Purpose:
%   Zef set surface resolution.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%   patch_data
%   surface_resolution
%
% Outputs:
%   patch_data
%
% Zef fields (observed):
%   zef.mesh_resolution (read)
%
% Calls (project):
%   zef_set_surface_resolution
%   zef_triangular_mesh_refinement
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[patch_data] = zef_set_surface_resolution(zef, patch_data, surface_resolution)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if not(isempty(patch_data.vertices))

    mesh_res = eval('zef.mesh_resolution');

    area_val = sum(sqrt(sum(cross(patch_data.vertices(patch_data.faces(:,2),:)'-patch_data.vertices(patch_data.faces(:,1),:)', patch_data.vertices(patch_data.faces(:,3),:)'-patch_data.vertices(patch_data.faces(:,1),:)').^2))/2);

    if surface_resolution <= 100

        face_count_from_volume = surface_resolution^2*area_val./mesh_res.^2;
        face_count_from_surface = size(patch_data.faces,1);

        if face_count_from_volume > face_count_from_surface

            n_ref = floor((log(face_count_from_volume) - log(face_count_from_surface))/log(4));
            for i = 1 : n_ref
                [patch_data.vertices, patch_data.faces] = zef_triangular_mesh_refinement(patch_data.vertices,patch_data.faces);
            end

        else

            patch_data = reducepatch(patch_data,face_count_from_volume);

        end

    else

        patch_data = reducepatch(patch_data,surface_resolution);

    end

end

end
