function zef = zef_DBS_strip_struct_open(zef)
% --- Zeffiro documentation header ---
% zef_DBS_strip_struct_open — Zef DBS strip struct open.
%
% Purpose:
%   Zef DBS strip struct open.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_DBS_strip_struct_open
%   zef_DBS_strip_struct_window
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_DBS_strip_struct_open(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


zef = zef_DBS_strip_struct_window(zef);
zef_DBS_strip_struct_init; 

end
