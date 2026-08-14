%ZEF_COMBINE_LEAD_FIELDS  Stack selected lf_bank_storage items into zef.L.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Vertical concat of normalized L and measurements. First item
%   supplies sensors, imaging_method, interpolation. zef.lf_normalization
%   indexes m/lead_field_normalization_functions.
%

zef.lf_item_selected = get(zef.h_lf_item_list,'value');
zef.L = [];
zef.measurements = [];
zef.source_positions = [];
zef.source_directions = [];
zef_delete_original_field;

zef.lf_n_aux = 0;
zef.lf_size_aux = 0;
zef_jj = 0;
% Vertical concat: each selected item is normalized, then stacked as extra
% sensor rows. The first selected item (sorted index) supplies sensors,
% imaging_method, and interpolation; later items do not replace those.
for zef_ii = sort(zef.lf_item_selected)
    zef_jj = zef_jj + 1;
    zef.lf_n_aux = zef.lf_n_aux + norm(zef.lf_bank_storage{zef_ii}.L,'fro').^2;
    zef.aux_field = str2func(zef.lf_normalization_functions_file_list{zef.lf_normalization});
    [zef.L_aux, zef.measurements_aux] = zef.aux_field(zef_ii);
    zef.measurements = [zef.measurements ; zef.measurements_aux];
    zef.L = [zef.L ; zef.L_aux];

    if zef_jj == 1
        zef.source_positions = [zef.lf_bank_storage{zef_ii}.source_positions];
        zef.source_directions = [zef.lf_bank_storage{zef_ii}.source_directions];
        zef.source_interpolation_ind = [zef.lf_bank_storage{zef_ii}.source_interpolation_ind];
        zef.parcellation_interp_ind = [zef.lf_bank_storage{zef_ii}.parcellation_interp_ind];

        zef.imaging_method = find(ismember(zef.imaging_method_cell, zef.lf_bank_storage{zef_ii}.imaging_method),1);
        zef.sensors = zef.lf_bank_storage{zef_ii}.sensors;
        if isvalid(zef.h_mesh_tool)
            zef_update_mesh_tool;
        end
        if size(zef.sensors,2) >= 3
            zef.s_points = zef.sensors(:,1:3);
        end
        if size(zef.sensors,2) > 3
            zef.s_directions = zef.sensors(:,4:end);
        end
        zef.s_scaling = 1;
        zef.s_x_correction = 0;
        zef.s_y_correction = 0;
        zef.s_z_correction = 0;
        zef.s_xy_rotation = 0;
        zef.s_yz_rotation = 0;
        zef.s_zx_rotation = 0;
        zef.s_affine_transform = {eye(4)};
        zef_update;

    end
end

if zef.lf_normalization == 2
    % Sorted Description index 2 is "Normalize Frobenius" with the shipped
    % files. Re-scale the stacked L so ||L||_F matches sqrt(sum_i ||L_i||_F^2).
    zef.aux_field = norm(zef.L,'fro');
    zef.measurements = sqrt(zef.lf_n_aux)*zef.measurements/norm(zef.L,'fro');
    zef.L = sqrt(zef.lf_n_aux)*zef.L/norm(zef.L,'fro');
end
zef = rmfield(zef,'lf_n_aux');
zef = rmfield(zef,'measurements_aux');
zef = rmfield(zef,'L_aux');

clear zef_i zef_jj;

zef_update;
