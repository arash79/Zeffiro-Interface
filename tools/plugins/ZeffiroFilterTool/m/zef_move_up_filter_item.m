%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef.filter_pipeline =  zef.filter_pipeline([zef.filter_pipeline_selected setdiff([1:length(zef.filter_pipeline)],zef — Zef.filter pipeline =  zef.filter pipeline([zef.filter pipeline selected setdiff([1:length(zef.filter pipeline)],zef.
%
% Purpose:
%   Zef.filter pipeline =  zef.filter pipeline([zef.filter pipeline selected setdiff([1:length(zef.filter pipeline)],zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.filter_pipeline =  zef.filter_pipeline([zef.filter_pipeline_selected setdiff([1:length(zef.filter_pipeline)],zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header




zef.filter_pipeline =  zef.filter_pipeline([zef.filter_pipeline_selected setdiff([1:length(zef.filter_pipeline)],zef.filter_pipeline_selected)]);
zef_update_filter_tool;
