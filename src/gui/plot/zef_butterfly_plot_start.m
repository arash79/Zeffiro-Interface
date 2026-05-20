%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef = zef_butterfly_plot_start(zef)
% --- Zeffiro documentation header ---
% zef_butterfly_plot_start — Zef butterfly plot start.
%
% Purpose:
%   Zef butterfly plot start.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.h_bf_apply (read)
%   zef.h_bf_cancel (read)
%   zef.h_bf_data_segment (read)
%   zef.h_bf_high_cut_frequency (read)
%   zef.h_bf_low_cut_frequency (read)
%   zef.h_bf_normalize_data (read)
%   zef.h_bf_plot (read)
%   zef.h_bf_sampling_frequency (read)
%   zef.h_bf_time_1 (read)
%   zef.h_bf_time_2 (read)
%   zef.h_butterfly_plot (read)
%   zef.measurements (read)
%
% Calls (project):
%   zef_butterfly_plot_start
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_butterfly_plot_start(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
