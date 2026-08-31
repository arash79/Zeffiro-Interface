%ZEF_ADD_LF_ITEM  Append current L, sensors, and measurements to lf_bank_storage.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. If zef.s_points is non-empty, zef_process_meshes first.
%   New cell: source_interpolation_ind, parcellation_interp_ind,
%   source_positions/directions, L, sensors, imaging_method string,
%   measurements, noise_data, lf_bank_scaling_factor, lf_tag.
%   Then zef_update_lf_bank_tool and zef_update.
%
%   See also zef_delete_lf_item, zef_combine_lead_fields, zef_lf_bank_tool.

if not(isempty(zef.s_points))
    zef_process_meshes;
end

zef_i = length(zef.lf_bank_storage)+1;

zef.lf_bank_storage{zef_i}.source_interpolation_ind = zef.source_interpolation_ind;
zef.lf_bank_storage{zef_i}.parcellation_interp_ind = zef.parcellation_interp_ind;
zef.lf_bank_storage{zef_i}.source_positions = zef.source_positions;
zef.lf_bank_storage{zef_i}.source_directions = zef.source_directions;
zef.lf_bank_storage{zef_i}.L = zef.L;
zef.lf_bank_storage{zef_i}.sensors = zef.sensors;
zef.lf_bank_storage{zef_i}.imaging_method = zef.imaging_method_cell{zef.imaging_method};
zef.lf_bank_storage{zef_i}.measurements = zef.measurements;
zef.lf_bank_storage{zef_i}.noise_data = zef.noise_data;
zef.lf_bank_storage{zef_i}.scaling_factor = zef.lf_bank_scaling_factor;
zef.lf_bank_storage{zef_i}.lf_tag = zef.lf_tag;

clear zef_i;

zef_update_lf_bank_tool;
zef_update;
