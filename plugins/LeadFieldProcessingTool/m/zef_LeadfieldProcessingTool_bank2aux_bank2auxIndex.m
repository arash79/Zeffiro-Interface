%ZEF_LEADFIELDPROCESSINGTOOL_BANK2AUX_BANK2AUXINDEX  bank{bank2auxIndex} → auxData.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Copies one bank cell into zef.LeadFieldProcessingTool.auxData.
%   Replace, Mag2Grad, and Combine set bank2auxIndex first.
%   Single assignment; no table refresh and no copy onto live zef.L.
%
%   See also zef_LeadfieldProcessingTool_aux2current,
%   zef_LeadFieldProcessingTool_aux2bank_new.

zef.LeadFieldProcessingTool.auxData=zef.LeadFieldProcessingTool.bank{zef.LeadFieldProcessingTool.bank2auxIndex};
