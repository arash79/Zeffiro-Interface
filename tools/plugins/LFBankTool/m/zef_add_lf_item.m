%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% if not(isempty(zef — If not(isempty(zef.
%
% Purpose:
%   If not(isempty(zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.L (read)
%   zef.imaging_method (read)
%   zef.imaging_method_cell (read)
%   zef.lf_bank_scaling_factor (read)
%   zef.lf_bank_storage (read)
%   zef.lf_tag (read)
%   zef.measurements (read)
%   zef.noise_data (read)
%   zef.parcellation_interp_ind (read)
%   zef.sensors (read)
%   zef.source_directions (read)
%   zef.source_interpolation_ind (read)
%   zef.source_positions (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if not(isempty(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header




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
