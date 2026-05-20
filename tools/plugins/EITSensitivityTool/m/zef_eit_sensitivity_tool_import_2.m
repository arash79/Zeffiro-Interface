% --- Zeffiro documentation header ---
% [zef.file zef.file_path] = uigetfile({'*.mat'},'Import interpolation',zef — [zef.file zef.file path] = uigetfile({'*.mat'},'Import interpolation',zef.
%
% Purpose:
%   [zef.file zef.file path] = uigetfile({'*.mat'},'Import interpolation',zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.eit_sensitivity_tool_data_2 (read)
%   zef.eit_sensitivity_tool_file_2 (read, write)
%   zef.file (read)
%   zef.file_path (read)
%   zef.h_eit_sensitivity_tool_file_2 (read)
%
% Side effects:
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `[zef.file zef.file_path] = uigetfile({'*.mat'},'Import interpolation',zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

[zef.file zef.file_path] = uigetfile({'*.mat'},'Import interpolation',zef.save_file_path);
if not(isequal(zef.file,0));
    [zef.eit_sensitivity_tool_data_2] = load([zef.file_path zef.file]);
    zef.eit_sensitivity_tool_file_2 = [zef.file_path zef.file];
    set(zef.h_eit_sensitivity_tool_file_2, 'Value', zef.eit_sensitivity_tool_file_2);
end
