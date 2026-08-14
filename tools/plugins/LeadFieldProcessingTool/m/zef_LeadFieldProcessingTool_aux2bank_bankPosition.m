%ZEF_LEADFIELDPROCESSINGTOOL_AUX2BANK_BANKPOSITION  Write auxData into bank{bankPosition}.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Called from aux2bank_new after bankPosition is set to the
%   new last slot. Overwrites that cell with auxData, then
%   zef_LeadfieldProcessingTool_updateTable. Does not grow the bank.
%
%   See also zef_LeadFieldProcessingTool_aux2bank_new.

zef.LeadFieldProcessingTool.bank{zef.LeadFieldProcessingTool.bankPosition}=zef.LeadFieldProcessingTool.auxData;

zef_LeadfieldProcessingTool_updateTable;

%zef.LeadFieldProcessingTool.auxData=[];
