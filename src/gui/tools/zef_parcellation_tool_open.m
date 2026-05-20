%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef = zef_parcellation_tool_open(zef)
% --- Zeffiro documentation header ---
% zef_parcellation_tool_open — Zef parcellation tool open.
%
% Purpose:
%   Zef parcellation tool open.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.font_size (read)
%   zef.h_parcellation_tool (read)
%   zef.h_time_series_tools_list (read)
%   zef.time_series_tools_name_list (read)
%
% Calls (project):
%   zef_parcellation_tool_open
%   zef_parcellation_tool_window
%   zef_update_parcellation
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_parcellation_tool_open(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
