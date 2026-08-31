function zef = zef_grouplasso_start(zef)
%ZEF_GROUPLASSO_START  Inverse tools entry for class Group Lasso (zef_inverse_run).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Distinct from EXP L1/L2 (legacy exp_iteration).
%
%   zef = zef_grouplasso_start
%   zef = zef_grouplasso_start(zef)
%
%   See also zef_open_class_inverse, inverse.GroupLassoInverter.

if nargin == 0
    zef = evalin('base', 'zef');
end

zef = zef_tool_start(zef, 'zef_grouplasso_window', 1/3, 0);

if nargout == 0
    assignin('base', 'zef', zef);
end

end
