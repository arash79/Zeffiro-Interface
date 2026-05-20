% --- Zeffiro documentation header ---
% zef.LeadFieldProcessingTool.bankPosition=zef.LeadFieldProcessingTool — Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
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
%   Programmatic: Call `zef.LeadFieldProcessingTool.bankPosition=zef.LeadFieldProcessingTool` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.LeadFieldProcessingTool.bankPosition=zef.LeadFieldProcessingTool.bankSize+1;
zef.LeadFieldProcessingTool.bankSize=zef.LeadFieldProcessingTool.bankSize+1;
zef_LeadFieldProcessingTool_aux2bank_bankPosition
