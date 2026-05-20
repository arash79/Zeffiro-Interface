% --- Zeffiro documentation header ---
% zef.LeadFieldProcessingTool.bank{zef.LeadFieldProcessingTool.bankPosition}=zef.LeadFieldProcessingTool — Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
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
%   Programmatic: Call `zef.LeadFieldProcessingTool.bank{zef.LeadFieldProcessingTool.bankPosition}=zef.LeadFieldProcessingTool` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.LeadFieldProcessingTool.bank{zef.LeadFieldProcessingTool.bankPosition}=zef.LeadFieldProcessingTool.auxData;

zef_LeadfieldProcessingTool_updateTable;

%zef.LeadFieldProcessingTool.auxData=[];
