%ZEF_LF_BANK_UPDATE_MEASUREMENTS  Copy live zef.measurements onto selected items.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Update-measurements button. Writes
%   lf_bank_storage{i}.measurements = zef.measurements for selected
%   indices. Then zef_update_lf_bank_tool. Does not touch L.
%
%   See also zef_lf_bank_update_noise_data.

zef.lf_item_selected = get(zef.h_lf_item_list,'value');

for zef_i = 1:length(zef.lf_bank_storage)

    if ismember(zef_i,zef.lf_item_selected)

        zef.lf_bank_storage{zef_i}.measurements = zef.measurements;

    end

end

clear zef_i;

zef_update_lf_bank_tool;
