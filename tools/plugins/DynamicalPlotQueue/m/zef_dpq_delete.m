function data_table = zef_dpq_delete(zef)
% --- Zeffiro documentation header ---
% zef_dpq_delete — Zef dpq delete.
%
% Purpose:
%   Zef dpq delete.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   data_table
%
% Zef fields (observed):
%   zef.dpq_selected (read)
%   zef.h_dynamical_plot_queue_description (read)
%   zef.h_dynamical_plot_queue_script (read)
%   zef.h_dynamical_plot_queue_table (read)
%
% Calls (project):
%   zef_dpq_delete
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[data_table] = zef_dpq_delete(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

data_table = eval('zef.h_dynamical_plot_queue_table.Data');

selected_ind = eval('zef.dpq_selected');
aux_ind = setdiff([1 : size(data_table,1)]', selected_ind);

data_table = data_table(aux_ind,:);

if size(data_table,1) >= aux_ind
    eval(['zef.h_dynamical_plot_queue_script.Value = ''' data_table{aux_ind,1} ''';']);
    eval(['zef.h_dynamical_plot_queue_description.Value = ''' data_table{aux_ind,4} ''';']);
elseif aux_ind > 1
    eval(['zef.h_dynamical_plot_queue_script.Value = ''' data_table{aux_ind-1,1} ''';']);
    eval(['zef.h_dynamical_plot_queue_description.Value = ''' data_table{aux_ind-1,4} ''';']);
else
    eval(['zef.h_dynamical_plot_queue_script.Value = '' '';']);
    eval(['zef.h_dynamical_plot_queue_description.Value = '''';']);
end

end
