function zef_ES_plot_data(varargin)
% --- Zeffiro documentation header ---
% zef_ES_plot_data — Zef ES plot data.
%
% Purpose:
%   Zef ES plot data.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   varargin
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.ES_plot_type (read)
%
% Calls (project):
%   zef_ES_optimizer_properties_show
%   zef_ES_plot_barplot
%   zef_ES_plot_current_pattern
%   zef_ES_plot_data
%   zef_ES_plot_error_chart
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_ES_plot_data(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if nargin == 0
    zef = evalin('base','zef');
else
    zef = varargin{1};
end

switch zef.ES_plot_type
    case 1
        zef_ES_plot_current_pattern(zef);
    case 2
        zef_ES_plot_barplot(zef);
    case 3
        zef_ES_plot_error_chart(zef);
    case 4
        zef_ES_optimizer_properties_show(zef);
    case 5
        zef_ES_plot_distance_curves;
end
end
