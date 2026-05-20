function data_table = zef_dpq_add(zef)
% --- Zeffiro documentation header ---
% zef_dpq_add — Zef dpq add.
%
% Purpose:
%   Zef dpq add.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   data_table
%
% Zef fields (observed):
%   zef.h_dynamical_plot_queue_table (read)
%
% Calls (project):
%   zef_dpq_add
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[data_table] = zef_dpq_add(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

data_table = eval('zef.h_dynamical_plot_queue_table.Data');

data_table(end+1,:) =  {'',true,'static',''};

end
