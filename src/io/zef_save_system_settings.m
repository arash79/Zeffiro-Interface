% --- Zeffiro documentation header ---
% zeffiro_interface — Zeffiro interface.
%
% Purpose:
%   Zeffiro interface.
%   Folder: Project load/save, segmentation import, figure import, FEM export.
%
% Zef fields (observed):
%   zef.h_system_settings_table (read)
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Primary startup: paths, `zef` struct, optional CLI import/save/export.
%   Programmatic: Call `zeffiro_interface` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

writecell(zef.h_system_settings_table.Data,[zef.program_path '/profile/zeffiro_interface.ini'],'FileType','text');
for zef_i = 1 : size(zef.h_system_settings_table.Data,1)
    evalin('base',['zef.' zef.h_system_settings_table.Data{zef_i,3} '= zef.h_system_settings_table.Data{zef_i,2};']);
end
