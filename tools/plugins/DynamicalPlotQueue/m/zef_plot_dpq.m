function zef_plot_dpq(type,zef)
% --- Zeffiro documentation header ---
% zef_plot_dpq — Renders or updates a plot_dpq figure from current `zef` state.
%
% Purpose:
%   Renders or updates a plot_dpq figure from current `zef` state.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   type
%   zef
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.dynamical_plot_queue_table (read)
%
% Calls (project):
%   zef_plot_dpq
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_plot_dpq(type, zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 1
    if evalin('base','exist(''zef'',''var'');')
        zef = evalin('caller','zef');
    else
        zef = [];
    end
end

if not(isempty(zef))

    dpq_table = eval('zef.dynamical_plot_queue_table');

    for dpq_ind = 1 : size(dpq_table,1)

        if str2num(dpq_table{dpq_ind,2})
            if isequal(dpq_table{dpq_ind,3},type)

                evalin('caller', dpq_table{dpq_ind,1});

            end
        end
    end
end
end
