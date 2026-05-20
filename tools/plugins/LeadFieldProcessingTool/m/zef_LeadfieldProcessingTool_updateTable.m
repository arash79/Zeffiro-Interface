% --- Zeffiro documentation header ---
% zef_LeadFieldProcessingTool_TableUpdate_index=zef.LeadFieldProcessingTool — Builds or applies a sensor lead-field matrix for forward/inverse pipelines.
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
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: Call `zef_LeadFieldProcessingTool_TableUpdate_index=zef.LeadFieldProcessingTool` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef_LeadFieldProcessingTool_TableUpdate_index=zef.LeadFieldProcessingTool.bankPosition;

if zef_LeadFieldProcessingTool_TableUpdate_index > size(zef.LeadFieldProcessingTool.app.BankTable.Data,1) %new data
    zef.LeadFieldProcessingTool.TableData={'', '', '', '', '', false};
else
    zef.LeadFieldProcessingTool.TableData=zef.LeadFieldProcessingTool.app.BankTable.Data(zef_LeadFieldProcessingTool_TableUpdate_index,:); %everything else should not happen?
end

if isempty(zef.LeadFieldProcessingTool.app.BankTable.Data)
    zef.LeadFieldProcessingTool.app.BankTable.Data=cell(1,6);
end

zef.LeadFieldProcessingTool.app.BankTable.Data(zef_LeadFieldProcessingTool_TableUpdate_index,:) = {...
    zef.LeadFieldProcessingTool.TableData{1},...
    zef.LeadFieldProcessingTool.bank{zef_LeadFieldProcessingTool_TableUpdate_index}.imaging_method_Name,...
    size(zef.LeadFieldProcessingTool.bank{zef_LeadFieldProcessingTool_TableUpdate_index}.sensors, 1),...
    size(zef.LeadFieldProcessingTool.bank{zef_LeadFieldProcessingTool_TableUpdate_index}.source_positions, 1),...
    zef.LeadFieldProcessingTool.bank{zef_LeadFieldProcessingTool_TableUpdate_index}.lead_field_id, ...
    zef.LeadFieldProcessingTool.TableData{6}   };

clear zef_LeadFieldProcessingTool_TableUpdate_index;
