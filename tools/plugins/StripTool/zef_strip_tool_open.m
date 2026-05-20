function zef = zef_strip_tool_open(zef)
% --- Zeffiro documentation header ---
% zef_strip_tool_open — Zef strip tool open.
%
% Purpose:
%   Zef strip tool open.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.strip_tool (read, write)
%
% Calls (project):
%   zef_strip_tool_init
%   zef_strip_tool_open
%   zef_strip_tool_update
%   zef_strip_tool_window
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_strip_tool_open(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if not(isfield(zef,'strip_tool'))
zef.strip_tool = struct; 
zef.strip_tool.strip_current_id = 1; 
end

zef.strip_tool.current_strip = 1;

zef = zef_strip_tool_window(zef);
zef = zef_strip_tool_init(zef); 
zef = zef_strip_tool_update(zef); 

end
