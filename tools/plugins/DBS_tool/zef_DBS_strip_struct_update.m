function zef = zef_DBS_strip_struct_update(zef)
%ZEF_DBS_STRIP_STRUCT_UPDATE  Run button: build probe contacts for the selected type.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_DBS_strip_struct_update(zef)
%
%   strip_type 1 → zef_electrode_strip_multiple_probe (40 contacts
%   per probe); type 2 → zef_Abbott_infinity_strip_multiple_probe
%   (8 per probe). Fills strip_struct.electrode_data. Does not copy
%   onto sensors (Attach electrodes does).
%
%   See also zef_DBS_update_electrodes.

    if zef.strip_struct.strip_type == 1
        zef = zef_electrode_strip_multiple_probe(zef);
    elseif zef.strip_struct.strip_type == 2
        zef = zef_Abbott_infinity_strip_multiple_probe(zef);
    end
end
