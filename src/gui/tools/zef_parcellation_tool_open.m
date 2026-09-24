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
zef = zef_ui_tag_handles(zef);
zef_ui_ready(zef.h_parcellation_tool);


if not(isempty(zef.time_series_tools_name_list))
    % A listbox treats newline characters inside an item as additional rows.
    % Keep each tool description on one line so that the selected row remains
    % aligned with the corresponding entry in time_series_tools_file_list.
    tool_names = cellfun(@(name) strtrim(regexprep(name, '\s+', ' ')), ...
        zef.time_series_tools_name_list, 'UniformOutput', false);
    set(zef.h_time_series_tools_list,'String',tool_names,'Value',1);
end

zef = zef_update_parcellation(zef);

end
