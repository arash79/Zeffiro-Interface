% --- Zeffiro documentation header ---
% zef.LeadFieldProcessingTool.bank=zef.LeadFieldProcessingTool.bank(~cell2mat( zef.LeadFieldProcessingTool.app.BankTable — Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
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
%   Programmatic: Call `zef.LeadFieldProcessingTool.bank=zef.LeadFieldProcessingTool.bank(~cell2mat( zef.LeadFieldProcessingTool.app.BankTable` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.LeadFieldProcessingTool.bank=zef.LeadFieldProcessingTool.bank(~cell2mat( zef.LeadFieldProcessingTool.app.BankTable.Data(:,6)));

zef.LeadFieldProcessingTool.app.BankTable.Data=zef.LeadFieldProcessingTool.app.BankTable.Data(~cell2mat( zef.LeadFieldProcessingTool.app.BankTable.Data(:,6)),:);

zef.LeadFieldProcessingTool.bankSize=size(zef.LeadFieldProcessingTool.bank,2);

% for zef_LeadFieldProcessingTool_deleteIndex=1:zef.LeadFieldProcessingTool.bankSize
% zef.LeadFieldProcessingTool.bankPosition=zef_LeadFieldProcessingTool_deleteIndex;
% zef_LeadfieldProcessingTool_BankTableLabelUpdate;
% end
%
% clear zef_LeadFieldProcessingTool_deleteIndex;
