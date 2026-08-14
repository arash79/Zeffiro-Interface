function zef = zef_ES_clear_plot_data(zef)
%ZEF_ES_CLEAR_PLOT_DATA  Delete ES plot handles (bar, colorbar, current markers) for the current plot_type.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Not bound in zef_ES_optimization_window. Deletes h_current_ES /
%   h_barplot_ES / h_colorbar_ES according to ES_plot_type 1–3.
%
%   zef = zef_ES_clear_plot_data()
%   zef = zef_ES_clear_plot_data(zef)
%
%   See also zef_ES_plot_data.
%

if nargin == 0 
zef = eval('zef');
end

switch eval('zef.ES_plot_type');
    case 1
        if isfield(eval('zef'),'h_current_ES')
            delete(zef.h_current_ES)
            zef = rmfield(zef,'h_current_ES');
        end
    case 2
        if isfield(eval('zef'),'h_barplot_ES')
            delete(zef.h_barplot_ES)
            zef = rmfield(zef,'h_barplot_ES');
            close(gcf);
        end
    case 3
        if isfield(eval('zef'),'h_colorbar_ES')
            delete(zef.h_colorbar_ES)
            zef = rmfield(zef,'h_colorbar_ES');
            close(gcf);
        end
end

if nargout == 0
    assignin('base','zef',zef);
end

end
