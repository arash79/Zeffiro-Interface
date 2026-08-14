function [L, measurements] = zef_lead_field_normalize_mean_data(lf_bank_index)
%ZEF_LEAD_FIELD_NORMALIZE_MEAN_DATA  Scale by mean column 2-norm of L.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [L, measurements] = zef_lead_field_normalize_mean_data(lf_bank_index)
%
%   Factor sqrt(n_sensors)/mean(sqrt(sum(L.^2)),2). Reads base storage.
%   Description: Normalize mean data.

L = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.L']);
measurements = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.measurements']);

L = sqrt(size(L,1))*L/mean(sqrt(sum(L.^2)),2);
measurements = sqrt(size(L,1))*measurements/mean(sqrt(sum(L.^2)),2);

end
