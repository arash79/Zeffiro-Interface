function zef = zef_ES_update_plot_data(varargin)
% --- Zeffiro documentation header ---
% zef_ES_update_plot_data — Zef ES update plot data.
%
% Purpose:
%   Zef ES update plot data.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   varargin
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.ES_plot_type (read)
%   zef.h_current_ES (read)
%   zef.h_current_coords (read)
%
% Calls (project):
%   zef_ES_optimizer_properties_show
%   zef_ES_update_plot_data
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_ES_update_plot_data(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if nargin == 0
    zef = evalin('base','zef');
else
    zef = varargin{1};
end

switch zef.ES_plot_type
    case 1
        [zef.h_current_ES, zef.h_current_coords] = zef_ES_plot_current_pattern;
    case 2
        zef_ES_plot_barplot;
    case 3
        zef_ES_plot_error_chart;
    case 4
        zef_ES_optimizer_properties_show(zef);
end

if nargout == 0
    assignin('base','zef',zef);
end

end
