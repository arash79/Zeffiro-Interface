%ZEF_ES_UPDATE_PARAMETER_VALUES  Read edited parameter-table cells back into zef.ES_*.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script (local function assign_common_parameters). First step of
%   zef_ES_optimization_update. α/ε cells are dB → linear (10^(dB/20)).
%   Solver 1 with method 4 maps the 6-row backpropagation table; others
%   map rows 1–17 (plus 18–19 step/constraint tolerance for Matlab LP).
%
%   See also zef_ES_init_parameter_table.
%

if ismember(zef.ES_opt_solver, 1)
    if zef.ES_opt_method ~= 4
        zef = assign_common_parameters(zef);
        zef.ES_step_tolerance       = str2double(zef.h_ES_parameter_table.Data{18,2});
        zef.ES_constraint_tolerance = str2double(zef.h_ES_parameter_table.Data{19,2});
    else
        zef.ES_total_max_current    = str2double(zef.h_ES_parameter_table.Data{1,2});
        zef.ES_max_current_channel  = str2double(zef.h_ES_parameter_table.Data{2,2});
        zef.ES_relative_weight_nnz  = str2double(zef.h_ES_parameter_table.Data{3,2});
        
        zef.ES_score_dose           = str2double(zef.h_ES_parameter_table.Data{4,2});
        zef.ES_boundary_color_limit = str2double(zef.h_ES_parameter_table.Data{5,2});
        zef.ES_roi_range            = str2double(zef.h_ES_parameter_table.Data{6,2});
    end
end

if ismember(zef.ES_opt_solver, 2:5)
    zef = assign_common_parameters(zef);
end

function zef = assign_common_parameters(zef)
%ASSIGN_COMMON_PARAMETERS  Map table rows 1–17 onto zef.ES_* (α/ε from dB).
zef.ES_alpha             = 10^(str2double(zef.h_ES_parameter_table.Data{1,2})/20);
zef.ES_alpha_max         = 10^(str2double(zef.h_ES_parameter_table.Data{2,2})/20);
zef.ES_epsilon_min          = 10^(str2double(zef.h_ES_parameter_table.Data{3,2})/20);
zef.ES_epsilon              = 10^(str2double(zef.h_ES_parameter_table.Data{4,2})/20);

zef.ES_total_max_current    = str2double(zef.h_ES_parameter_table.Data{5,2});
zef.ES_max_current_channel  = str2double(zef.h_ES_parameter_table.Data{6,2});
zef.ES_relative_weight_nnz  = str2double(zef.h_ES_parameter_table.Data{7,2});

zef.ES_score_dose           = str2double(zef.h_ES_parameter_table.Data{8,2});
zef.ES_step_size            = str2double(zef.h_ES_parameter_table.Data{9,2});
zef.ES_source_density       = str2double(zef.h_ES_parameter_table.Data{10,2});
zef.ES_acceptable_threshold = str2double(zef.h_ES_parameter_table.Data{11,2});
zef.ES_boundary_color_limit = str2double(zef.h_ES_parameter_table.Data{12,2});
zef.ES_roi_range            = str2double(zef.h_ES_parameter_table.Data{13,2});
zef.ES_solver_tolerance     = str2double(zef.h_ES_parameter_table.Data{14,2});
zef.ES_display              = (zef.h_ES_parameter_table.Data{15,2});

if ismember(zef.ES_opt_solver, [1 4 5])
    zef.ES_max_n_iterations     = str2double(zef.h_ES_parameter_table.Data{16,2});
    zef.ES_max_time             = str2double(zef.h_ES_parameter_table.Data{17,2});
end

end
