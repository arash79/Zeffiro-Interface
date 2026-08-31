function [L, measurements] = zef_lead_field_whitening_diagonal_identity(lf_bank_index)
%ZEF_LEAD_FIELD_WHITENING_DIAGONAL_IDENTITY  Whiten after scaling noise cov to unit diagonal.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [L, measurements] = zef_lead_field_whitening_diagonal_identity(lf_bank_index)
%
%   D^{-1/2} cov D^{-1/2} then inv(sqrtm). Needs noise_data on the
%   bank item. Does not assignin.
%
%   See also zef_lead_field_whitening.
%   Description: Whitening diagonal identity.

L = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.L']);
measurements = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.measurements']);
noise_data = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.noise_data']);

aux_mat_1 = cov(noise_data');
aux_mat_2 = inv(diag(sqrt(diag(aux_mat_1))));
aux_mat_1 = aux_mat_2*aux_mat_1*aux_mat_2;
inv_C = inv(sqrtm(aux_mat_1));

L = inv_C*L;
measurements = inv_C*measurements;

end
