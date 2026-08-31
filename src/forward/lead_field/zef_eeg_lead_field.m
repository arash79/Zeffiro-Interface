function zef = zef_eeg_lead_field(zef)
%ZEF_EEG_LEAD_FIELD  EEG isotropic lead field (type 1).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Alias for zef_eeg_lead_field_isotropic. Kept for zef_eeg_make_all and
%   study scripts. Mesh-tool INI rows call the isotropic name directly.
%
%   zef = zef_eeg_lead_field(zef)
%
%   See also zef_eeg_lead_field_isotropic, zef_eeg_make_all.

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_eeg_lead_field_isotropic(zef);

if nargout == 0
    assignin('base','zef',zef);
end

end
