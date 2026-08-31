function zef_ES_plot_data(varargin)
%ZEF_ES_PLOT_DATA  Plot data button: dispatch on zef.ES_plot_type (pattern, bar, error, properties, distance).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   ButtonPushedFcn of h_ES_plot_data. ES_plot_type Items in the window are
%   {'Current pattern','Electrode potentials','Error Chart','Show properties',
%   'Plot distance curves'}; case 2 still calls zef_ES_plot_barplot
%   (electrode currents, figure title "ES electrode potentials").
%
%   zef_ES_plot_data()
%   zef_ES_plot_data(zef)
%
%   See also zef_ES_plot_current_pattern, zef_ES_plot_barplot.
%

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
