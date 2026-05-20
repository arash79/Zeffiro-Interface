function zef = zef_strip_tool_add(zef)
% --- Zeffiro documentation header ---
% zef_strip_tool_add — Zef strip tool add.
%
% Purpose:
%   Zef strip tool add.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.current_sensors (read)
%   zef.strip_tool (read)
%
% Calls (project):
%   zef_strip_tool_add
%   zef_strip_tool_init
%   zef_strip_tool_update
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_strip_tool_add(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


zef.strip_tool.strip_current_id = zef.strip_tool.strip_current_id + 1; 

zef.strip_tool.current_strip = length(zef.([zef.current_sensors '_strip_cell']))+1;

zef = zef_strip_tool_init(zef);
zef = zef_strip_tool_update(zef);

end
