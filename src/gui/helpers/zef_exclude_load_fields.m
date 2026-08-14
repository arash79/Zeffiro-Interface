function exclude_fields = zef_exclude_load_fields
%ZEF_EXCLUDE_LOAD_FIELDS  Cellstr of zef fields not to restore from a .mat.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Currently only 'dti_tensor' (can be gigabytes). No first-party caller:
%   zef_load does not invoke this list. Keep in sync if load-time skipping
%   is wired later.
%
%   exclude_fields = zef_exclude_load_fields()

exclude_fields = {
    'dti_tensor'  % DTI tensors can be very large (GB), load only when needed
    % Add other fields here if needed
};

end
