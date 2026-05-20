function direction = zef_nse_vel_dir(zef,nse_field)
% --- Zeffiro documentation header ---
% zef_nse_vel_dir — Zef nse vel dir.
%
% Purpose:
%   Zef nse vel dir.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%   nse_field
%
% Outputs:
%   direction
%
% Zef fields (observed):
%   zef.domain_labels (read)
%   zef.nodes (read)
%   zef.source_positions (read)
%   zef.tetra (read)
%
% Calls (project):
%   zef_get_submesh
%   zef_nse_vel_dir
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[direction] = zef_nse_vel_dir(zef, nse_field)` with project root and `src` on the path.
% --- End Zeffiro documentation header

roi_ind = find(sqrt(sum((zef.source_positions - repmat([str2double(nse_field.h_roi_x.Value) str2double(nse_field.h_roi_y.Value) str2double(nse_field.h_roi_z.Value)],size(zef.source_positions,1),1)).^2,2))<= nse_field.roi_radius);
towards = [nse_field.dir_v_x nse_field.dir_v_y nse_field.dir_v_z];
c_ind_1_domain = find(ismember(zef.domain_labels,nse_field.artery_domain_ind));
[v_1_nodes, ~, ~] = zef_get_submesh(zef.nodes, zef.tetra, c_ind_1_domain);
dir_aux = -v_1_nodes(roi_ind,:)+towards;
direction = dir_aux./sqrt(dir_aux(:,1).^2+dir_aux(:,2).^2+dir_aux(:,3).^2);
end
