% --- Zeffiro documentation header ---
% zef.LeadFieldProcessingTool.auxData=zef.LeadFieldProcessingTool.bank{zef.LeadFieldProcessingTool — Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%
% Purpose:
%   Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.LeadFieldProcessingTool.auxData=zef.LeadFieldProcessingTool.bank{zef.LeadFieldProcessingTool` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.LeadFieldProcessingTool.auxData=zef.LeadFieldProcessingTool.bank{zef.LeadFieldProcessingTool.bank2auxIndex};
