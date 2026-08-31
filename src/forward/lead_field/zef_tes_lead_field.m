function zef = zef_tes_lead_field(zef)
%ZEF_TES_LEAD_FIELD  TES / tES isotropic lead field (type 5).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Alias for zef_tes_lead_field_isotropic. Kept for zef_tes_make_all.
%   Mesh-tool INI rows call the isotropic name directly.
%
%   zef = zef_tes_lead_field(zef)
%
%   See also zef_tes_lead_field_isotropic, zef_tes_make_all.

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tes_lead_field_isotropic(zef);

if nargout == 0
    assignin('base','zef',zef);
end

end
