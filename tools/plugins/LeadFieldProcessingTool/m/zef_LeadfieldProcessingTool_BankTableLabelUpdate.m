% --- Zeffiro documentation header ---
% for zef_LeadFieldProcessingTool_TableUpdate_index2=1:size(zef.LeadFieldProcessingTool.app.BankTable — Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
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
%   Programmatic: Call `for zef_LeadFieldProcessingTool_TableUpdate_index2=1:size(zef.LeadFieldProcessingTool.app.BankTable` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

for zef_LeadFieldProcessingTool_TableUpdate_index2=1:size(zef.LeadFieldProcessingTool.app.BankTable.Data,1)

    zef.LeadFieldProcessingTool.bank{zef_LeadFieldProcessingTool_TableUpdate_index2}.lf_tag=zef.LeadFieldProcessingTool.app.BankTable.Data{zef_LeadFieldProcessingTool_TableUpdate_index2,1};

end

clear zef_LeadFieldProcessingTool_TableUpdate_index2;
