function [L, measurements] = zef_lead_field_no_normalization(lf_bank_index)
%ZEF_LEAD_FIELD_NO_NORMALIZATION  Return bank L and measurements unscaled.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [L, measurements] = zef_lead_field_no_normalization(lf_bank_index)
%
%   Reads zef.lf_bank_storage{index} from base. Called from
%   zef_combine_lead_fields via str2func. Does not assignin.
%   Description: No normalization.

L = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.L']);
measurements = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.measurements']);

end
