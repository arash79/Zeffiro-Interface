function zef = zef_eloreta_start(zef)
%ZEF_ELORETA_START  Inverse tools entry for class eLORETA (zef_inverse_run).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Opens a parameter dialog for inverse.ELORETAInverter. Does not call
%   legacy plugin iteration functions. noise_cov is not exposed: the
%   operator does not use it.
%
%   zef = zef_eloreta_start
%   zef = zef_eloreta_start(zef)
%
%   See also zef_open_class_inverse, inverse.ELORETAInverter.

if nargin == 0
    zef = evalin('base', 'zef');
end

zef = zef_tool_start(zef, 'zef_eloreta_window', 1/3, 0);

if nargout == 0
    assignin('base', 'zef', zef);
end

end
