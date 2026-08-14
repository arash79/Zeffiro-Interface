%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef = zef_butterfly_plot_start(zef)
%ZEF_BUTTERFLY_PLOT_START  Build the butterfly window and fill bf_* widgets.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Called via zef_tool_start from zef_butterfly_plot. Runs
%   zef_butterfly_plot_app (uicontrol figure), names it 'ZEFFIRO
%   Interface: Butterfly plot', zef_init_butterfly_plot, and enables
%   h_bf_data_segment only when zef.measurements is a cell. Does not
%   draw until **Plot**.
%
%   See also zef_butterfly_plot_app, zef_init_butterfly_plot.
zef_butterfly_plot_app;

set(zef.h_butterfly_plot,'Name','ZEFFIRO Interface: Butterfly plot');
set(findobj(zef.h_butterfly_plot.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_butterfly_plot.Children,'-property','FontSize'),'FontSize',9);
zef_init_butterfly_plot;
if isfield(zef,'measurements')
    if iscell(zef.measurements)
        set(zef.h_bf_data_segment,'enable','on');
    end
    if not(iscell(zef.measurements))
        set(zef.h_bf_data_segment,'enable','off');
    end
end
uistack(flipud([zef.h_bf_sampling_frequency ; zef.h_bf_low_cut_frequency ;
    zef.h_bf_high_cut_frequency ; zef.h_bf_time_1 ; zef.h_bf_time_2; zef.h_bf_data_segment ; zef.h_bf_cancel ; zef.h_bf_normalize_data;
    zef.h_bf_apply; zef.h_bf_plot  ]),'top');
