function zef = zef_ramus_class_start(zef)
%ZEF_RAMUS_CLASS_START  Inverse tools entry for class RAMUS (zef_inverse_run).
%
%   Zeffiro Interface.
%   Copyright 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Opens a parameter dialog for inverse.RAMUSInverter. Distinct from the
%   legacy RAMUS Inversion plugin (zef_ramus_inversion_tool).
%
%   zef = zef_ramus_class_start
%   zef = zef_ramus_class_start(zef)
%
%   See also zef_open_class_inverse, inverse.RAMUSInverter.

if nargin == 0
    zef = evalin('base', 'zef');
end

zef = zef_tool_start(zef, 'zef_ramus_class_window', 1/3, 0);

if nargout == 0
    assignin('base', 'zef', zef);
end

end
