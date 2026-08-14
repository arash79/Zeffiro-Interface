%ZEF_LF_BANK_UPDATE_NOISE_DATA  Copy live zef.noise_data onto selected items.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Update-noise button. Writes lf_bank_storage{i}.noise_data
%   = zef.noise_data. Then zef_update_lf_bank_tool. Used by whitening
%   normalizers at merge time.
%
%   See also zef_lf_bank_update_measurements.

for zef_i = 1:length(zef.lf_bank_storage)

    if ismember(zef_i,zef.lf_item_selected)

        zef.lf_bank_storage{zef_i}.noise_data = zef.noise_data;

    end

end

clear zef_i;

zef_update_lf_bank_tool;
