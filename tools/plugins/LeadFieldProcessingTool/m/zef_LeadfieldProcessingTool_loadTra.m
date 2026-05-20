% --- Zeffiro documentation header ---
% ', 'select tra file', '* — Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%
% Purpose:
%   Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.LeadFieldProcessingTool (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `', 'select tra file', '*` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

[zef.LeadFieldProcessingTool.traName, zef.LeadFieldProcessingTool.traPath]=uigetfile('./', 'select tra file', '*.dat');

zef.LeadFieldProcessingTool.tra=readmatrix(strcat(zef.LeadFieldProcessingTool.traPath, zef.LeadFieldProcessingTool.traName));
