%ZEF_LEADFIELDPROCESSINGTOOL_BANKTABLELABELUPDATE  BankTable column 1 → each bank.lf_tag.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. BankTable.CellEditCallback from LeadFieldProcessingTool_start.
%   Writes app.BankTable.Data{i,1} onto bank{i}.lf_tag. Does not refresh
%   the current-lead-field table.

for zef_LeadFieldProcessingTool_TableUpdate_index2=1:size(zef.LeadFieldProcessingTool.app.BankTable.Data,1)

    zef.LeadFieldProcessingTool.bank{zef_LeadFieldProcessingTool_TableUpdate_index2}.lf_tag=zef.LeadFieldProcessingTool.app.BankTable.Data{zef_LeadFieldProcessingTool_TableUpdate_index2,1};

end

clear zef_LeadFieldProcessingTool_TableUpdate_index2;
