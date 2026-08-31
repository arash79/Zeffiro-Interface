function zef = zef_halpr_start(zef)
%ZEF_HALPR_START  Inverse tools entry for class HALpR (zef_inverse_run).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Distinct from Standardized Hierarchical L1 MAP (zef_sl1_iteration).
%
%   zef = zef_halpr_start
%   zef = zef_halpr_start(zef)
%
%   See also zef_open_class_inverse, inverse.HALpRInverter.

if nargin == 0
    zef = evalin('base', 'zef');
end

zef = zef_tool_start(zef, 'zef_halpr_window', 1/3, 0);

if nargout == 0
    assignin('base', 'zef', zef);
end

end
