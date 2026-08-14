%ZEF_LEADFIELDPROCESSINGTOOL_AUX2BANK_NEW  Append auxData as a new bank cell.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Increments bankSize, sets bankPosition to the new index,
%   then zef_LeadFieldProcessingTool_aux2bank_bankPosition. Used by Add,
%   Mag2Grad, and Combine after they fill auxData.
%
%   See also zef_LeadFieldProcessingTool_aux2bank_bankPosition.

zef.LeadFieldProcessingTool.bankPosition=zef.LeadFieldProcessingTool.bankSize+1;
zef.LeadFieldProcessingTool.bankSize=zef.LeadFieldProcessingTool.bankSize+1;
zef_LeadFieldProcessingTool_aux2bank_bankPosition
