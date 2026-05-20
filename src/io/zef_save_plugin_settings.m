% --- Zeffiro documentation header ---
% zef.plugin_cell = zef.h_plugin_settings_table — Zef.plugin cell = zef.h plugin settings table.
%
% Purpose:
%   Zef.plugin cell = zef.h plugin settings table.
%   Folder: Project load/save, segmentation import, figure import, FEM export.
%
% Zef fields (observed):
%   zef.h_plugin_settings_table (read)
%   zef.plugin_cell (read)
%   zef.profile_name (read)
%   zef.program_path (read)
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.plugin_cell = zef.h_plugin_settings_table` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.plugin_cell = zef.h_plugin_settings_table.Data;
writecell(zef.plugin_cell,[zef.program_path '/profile/' zef.profile_name '/zeffiro_plugins.ini'],'FileType','text');
for zef_i = 1 : size(zef.h_plugin_settings_table.Data,1)
    evalin('base',['zef.' zef.h_plugin_settings_table.Data{zef_i,3} '= zef.h_plugin_settings_table.Data{zef_i,2};']);
end
