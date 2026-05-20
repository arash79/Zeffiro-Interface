%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef.filter_pipeline_selected = get(zef — Zef.filter pipeline selected = get(zef.
%
% Purpose:
%   Zef.filter pipeline selected = get(zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.filter_pipeline (read, write)
%   zef.filter_pipeline_list (read, write)
%   zef.filter_pipeline_selected (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.filter_pipeline_selected = get(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header




zef.filter_pipeline_selected = get(zef.h_filter_pipeline_list,'value');

zef_j = 0;
for zef_i = 1 : length(zef.filter_pipeline_list)
    if not(ismember(zef_i,zef.filter_pipeline_selected))
        zef_j = zef_j + 1;
        zef.filter_pipeline{zef_j} =  zef.filter_pipeline{zef_i};
        zef.filter_pipeline_list{zef_j} = zef.filter_pipeline_list{zef_i};
    end
end

zef.filter_pipeline = zef.filter_pipeline(1:zef_j);
zef.filter_pipeline_list = zef.filter_pipeline_list(1:zef_j);

zef.filter_pipeline_selected = [];

clear zef_i zef_j;

zef_update_filter_tool;
