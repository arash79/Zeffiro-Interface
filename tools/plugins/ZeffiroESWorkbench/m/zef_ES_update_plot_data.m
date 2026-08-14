function zef = zef_ES_update_plot_data(varargin)
%ZEF_ES_UPDATE_PLOT_DATA  Refresh current-pattern / bar / error / properties graphics.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Same ES_plot_type switch as zef_ES_plot_data cases 1–4 (no distance
%   curves). Not bound in zef_ES_optimization_window (Plot data uses
%   zef_ES_plot_data). ES_update_plot_data is an init flag only.
%
%   zef = zef_ES_update_plot_data()
%   zef = zef_ES_update_plot_data(zef)
%
%   See also zef_ES_plot_data.
%

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
