function [L, measurements] = zef_lead_field_whitening(lf_bank_index)
%ZEF_LEAD_FIELD_WHITENING  Left-multiply L and measurements by inv(sqrtm(cov(noise'))).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [L, measurements] = zef_lead_field_whitening(lf_bank_index)
%
%   Needs lf_bank_storage{index}.noise_data. Full covariance, not
%   diagonal-normalized. Does not assignin.
%
%   See also zef_lead_field_whitening_diagonal_identity.
%   Description: Whitening.

L = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.L']);
measurements = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.measurements']);
noise_data = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.noise_data']);

aux_mat_1 = cov(noise_data');
%aux_mat_2 = inv(diag(sqrt(diag(aux_mat_1))));
%aux_mat_1 = aux_mat_2*aux_mat_1*aux_mat_2;
inv_C = inv(sqrtm(aux_mat_1));

L = inv_C*L;
measurements = inv_C*measurements;

end
