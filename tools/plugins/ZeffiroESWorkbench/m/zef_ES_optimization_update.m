% --- Zeffiro documentation header ---
% zef_ES_update_parameter_values; — Zef ES update parameter values;.
%
% Purpose:
%   Zef ES update parameter values;.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.ES_HPO_search_method (read, write)
%   zef.ES_fixed_active_electrodes (read, write)
%   zef.ES_inv_colormap (read, write)
%   zef.ES_obj_fun (read, write)
%   zef.ES_obj_fun_2 (read, write)
%   zef.ES_opt_algorithm (read, write)
%   zef.ES_opt_algorithm_list (read)
%   zef.ES_opt_method (read, write)
%   zef.ES_opt_solver (read, write)
%   zef.ES_plot_type (read, write)
%   zef.ES_threshold_condition (read, write)
%   zef.h_ES_HPO_search_method (read)
%   zef.h_ES_fixed_active_electrodes (read)
%   zef.h_ES_inv_colormap (read)
%   zef.h_ES_obj_fun (read)
%   … (6 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef_ES_update_parameter_values;` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef_ES_update_parameter_values;

zef.ES_opt_solver               = zef.h_ES_opt_solver.Value;
zef.ES_opt_method               = zef.h_ES_opt_method.Value;
zef.ES_opt_algorithm            = lower(zef.ES_opt_algorithm_list{zef.h_ES_opt_algorithm.Value});

zef.ES_obj_fun                  = zef.h_ES_obj_fun.Value;
zef.ES_obj_fun_2                = zef.h_ES_obj_fun_2.Value;
zef.ES_threshold_condition      = zef.h_ES_threshold_condition.Value;

zef.ES_HPO_search_method        = zef.h_ES_HPO_search_method.Value;

zef.ES_inv_colormap             = get(zef.h_ES_inv_colormap,'Value');
zef.ES_plot_type                = get(zef.h_ES_plot_type,'Value');

zef.ES_fixed_active_electrodes  = get(zef.h_ES_fixed_active_electrodes,'Value');

if not(ismember(zef.ES_opt_method, zef.h_ES_opt_method.ItemsData))
    zef.ES_opt_method = zef.h_ES_opt_method.ItemsData(1);
end

zef_ES_init_parameter_table;

zef.ES_opt_solver               = zef.h_ES_opt_solver.Value;
zef.ES_opt_method               = zef.h_ES_opt_method.Value;
zef.ES_opt_algorithm            = lower(zef.ES_opt_algorithm_list{zef.h_ES_opt_algorithm.Value});

zef.ES_obj_fun                  = zef.h_ES_obj_fun.Value;
zef.ES_obj_fun_2                = zef.h_ES_obj_fun_2.Value;
zef.ES_threshold_condition      = zef.h_ES_threshold_condition.Value;

zef.ES_HPO_search_method        = zef.h_ES_HPO_search_method.Value;

zef.ES_inv_colormap             = get(zef.h_ES_inv_colormap,'Value');
zef.ES_plot_type                = get(zef.h_ES_plot_type,'Value');

zef.ES_fixed_active_electrodes  = get(zef.h_ES_fixed_active_electrodes,'Value');

if not(ismember(zef.ES_opt_method, zef.h_ES_opt_method.ItemsData))
    zef.ES_opt_method = zef.h_ES_opt_method.ItemsData(1);
end
