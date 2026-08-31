function direction = zef_nse_vel_dir(zef,nse_field)
%ZEF_NSE_VEL_DIR  Unit direction from ROI node toward dir_v_* on the artery submesh.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Used by zef_nse_separate_waves_roi. ROI centre is read from the widget
%   strings h_roi_x/y/z; toward-point is nse_field.dir_v_*. Artery submesh
%   via zef_get_submesh.
%
%   direction = zef_nse_vel_dir(zef, nse_field)
%
%   See also zef_nse_dir_v_node, zef_nse_separate_waves_roi.
%

roi_ind = find(sqrt(sum((zef.source_positions - repmat([str2double(nse_field.h_roi_x.Value) str2double(nse_field.h_roi_y.Value) str2double(nse_field.h_roi_z.Value)],size(zef.source_positions,1),1)).^2,2))<= nse_field.roi_radius);
towards = [nse_field.dir_v_x nse_field.dir_v_y nse_field.dir_v_z];
c_ind_1_domain = find(ismember(zef.domain_labels,nse_field.artery_domain_ind));
[v_1_nodes, ~, ~] = zef_get_submesh(zef.nodes, zef.tetra, c_ind_1_domain);
dir_aux = -v_1_nodes(roi_ind,:)+towards;
direction = dir_aux./sqrt(dir_aux(:,1).^2+dir_aux(:,2).^2+dir_aux(:,3).^2);
end
