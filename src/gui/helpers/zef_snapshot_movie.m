% --- Zeffiro documentation header ---
% [zef.file zef.file_path zef.file_index] = uiputfile({'*.jpg';'*.tif';'*.png';'*.avi'},'Save visualization as...',zef — [zef.file zef.file path zef.file index] = uiputfile({'*.jpg';'*.tif';'*.png';'*.avi'},'Save visualization as...',zef.
%
% Purpose:
%   [zef.file zef.file path zef.file index] = uiputfile({'*.jpg';'*.tif';'*.png';'*.avi'},'Save visualization as...',zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.explode_everything (read)
%   zef.file (read)
%
% Calls (project):
%   zef_print_meshes
%   zef_process_meshes
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `[zef.file zef.file_path zef.file_index] = uiputfile({'*.jpg';'*.tif';'*.png';'*.avi'},'Save visualization as...',zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

[zef.file zef.file_path zef.file_index] = uiputfile({'*.jpg';'*.tif';'*.png';'*.avi'},'Save visualization as...',zef.save_file_path);
if not(isequal(zef.file,0));
    zef_process_meshes(zef,zef.explode_everything);
    zef_print_meshes([]);
end;
