% --- Zeffiro documentation header ---
% if ismember(zef — If ismember(zef.
%
% Purpose:
%   If ismember(zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.ES_acceptable_threshold (read, write)
%   zef.ES_alpha (read, write)
%   zef.ES_alpha_max (read, write)
%   zef.ES_boundary_color_limit (read, write)
%   zef.ES_constraint_tolerance (read, write)
%   zef.ES_display (read, write)
%   zef.ES_epsilon (read, write)
%   zef.ES_epsilon_min (read, write)
%   zef.ES_max_current_channel (read, write)
%   zef.ES_max_n_iterations (read, write)
%   zef.ES_max_time (read, write)
%   zef.ES_opt_method (read)
%   zef.ES_opt_solver (read)
%   zef.ES_relative_weight_nnz (read, write)
%   zef.ES_roi_range (read, write)
%   … (7 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if ismember(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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
