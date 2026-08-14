%ZEF_LEADFIELDPROCESSINGTOOL_UPDATETABLE  Write one BankTable row from bank{bankPosition}.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Called after add/append/mag2grad and from refresh. Columns:
%   label, imaging_method_Name, n_sensors, n_sources, lead_field_id,
%   checkbox (preserved). Grows the table if bankPosition is past the last row.
%
%   See also zef_LeadfieldProcessingTool_refresh.

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
