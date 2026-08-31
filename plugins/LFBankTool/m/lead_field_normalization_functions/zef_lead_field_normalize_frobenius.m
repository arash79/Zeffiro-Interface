function [L, measurements] = zef_lead_field_normalize_frobenius(lf_bank_index)
%ZEF_LEAD_FIELD_NORMALIZE_FROBENIUS  sqrt(n_sensors)*L / ||L||_F for one bank item.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [L, measurements] = zef_lead_field_normalize_frobenius(lf_bank_index)
%
%   Reads zef.lf_bank_storage{index}.L and .measurements from base.
%   Scales measurements with the same factor as L. Does not assignin.
%
%   See also zef_lead_field_no_normalization, zef_combine_lead_fields.
%
%   Description: Normalize Frobenius.

L = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.L']);
measurements = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.measurements']);

L = sqrt(size(L,1))*L/norm(L,'fro');
measurements = sqrt(size(L,1))*measurements/norm(L,'fro');

end
