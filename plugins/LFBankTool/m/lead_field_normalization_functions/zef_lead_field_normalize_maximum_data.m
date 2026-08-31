function [L, measurements] = zef_lead_field_normalize_maximum_data(lf_bank_index)
%ZEF_LEAD_FIELD_NORMALIZE_MAXIMUM_DATA  Scale L and measurements by max(L,'fro').
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [L, measurements] = zef_lead_field_normalize_maximum_data(lf_bank_index)
%
%   Reads storage from base. Same factor on measurements. Does not assignin.
%   Description: Normalize maximum data.

L = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.L']);
measurements = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.measurements']);

L = L/max(L,'fro');
measurements = measurements/max(L,'fro');

end
