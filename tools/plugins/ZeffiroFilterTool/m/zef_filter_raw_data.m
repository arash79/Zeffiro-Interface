% --- Zeffiro documentation header ---
% zef_update_filter_tool; — Syncs GUI control values into `zef` for filter_tool;.
%
% Purpose:
%   Syncs GUI control values into `zef` for filter_tool;.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.aux_field (read, write)
%   zef.filter_parameters (read, write)
%   zef.filter_pipeline (read)
%   zef.filter_pipeline_list (read)
%   zef.filter_pipeline_selected (read, write)
%   zef.processed_data (read, write)
%   zef.raw_data (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef_update_filter_tool;` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef_update_filter_tool;
zef.processed_data = zef.raw_data;
if isstr(zef.filter_pipeline_selected)
    zef.filter_pipeline_selected = {zef.filter_pipeline_selected};
end
for zef_j = 1 : length(zef.filter_pipeline_list)
    zef.aux_field = str2func(zef.filter_pipeline{zef_j}.file);
    zef.filter_parameters = zef.filter_pipeline{zef_j}.parameters(:,2);
    zef.processed_data = zef.aux_field(zef.processed_data, zef.filter_parameters{:});
end

clear zef_i zef_j
