%ZEF_LEADFIELDPROCESSINGTOOL_DELETE  Drop checked bank rows (BankTable column 6).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. deleteButton. Keeps bank cells and table rows where column 6
%   is false; sets bankSize from the remaining bank width. Does not
%   touch live zef.L.
%
%   See also zef_LeadFieldProcessingTool_addCurrentData2bank,
%   zef_LeadfieldProcessingTool_refresh.

zef.LeadFieldProcessingTool.bank=zef.LeadFieldProcessingTool.bank(~cell2mat( zef.LeadFieldProcessingTool.app.BankTable.Data(:,6)));

zef.LeadFieldProcessingTool.app.BankTable.Data=zef.LeadFieldProcessingTool.app.BankTable.Data(~cell2mat( zef.LeadFieldProcessingTool.app.BankTable.Data(:,6)),:);

zef.LeadFieldProcessingTool.bankSize=size(zef.LeadFieldProcessingTool.bank,2);
