function zef = zef_DBS_update_electrodes(zef)
%ZEF_DBS_UPDATE_ELECTRODES  Attach-electrodes button: copy contacts onto sensors.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_DBS_update_electrodes(zef)
%
%   Thin wrapper around zef_DBS_attach_electrodes.
%
%   See also zef_DBS_attach_electrodes.

zef=zef_DBS_attach_electrodes(zef);
end
