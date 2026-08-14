%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef = zef_parcellation_tool_open(zef)
%ZEF_PARCELLATION_TOOL_OPEN  Initialize parcellation and open tool window.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. zef_init_parcellation then zef_parcellation_tool_window;
%   sets Name to "ZEFFIRO Interface: Parcellation tool"; fills the
%   time-series tool list; zef_update_parcellation.
zef_init_parcellation;

zef = zef_parcellation_tool_window(zef);
set(zef.h_parcellation_tool,'Name','ZEFFIRO Interface: Parcellation tool');
set(findobj(zef.h_parcellation_tool.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_parcellation_tool.Children,'-property','FontSize'),'FontSize',zef.font_size);


if not(isempty(zef.time_series_tools_name_list))
    set(zef.h_time_series_tools_list,'string',zef.time_series_tools_name_list,'Value',1);
end

zef = zef_update_parcellation(zef);

end
