function zef = zef_ukfnmm_start(zef)
%ZEF_UKFNMM_START  Inverse tools entry for class UKF-NMM (zef_inverse_run).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Opens a parameter dialog for inverse.UKFNMMInverter. Distinct from the
%   legacy Kalman plugin (zef_KF).
%
%   zef = zef_ukfnmm_start
%   zef = zef_ukfnmm_start(zef)
%
%   See also zef_open_class_inverse, inverse.UKFNMMInverter.

if nargin == 0
    zef = evalin('base', 'zef');
end

zef = zef_tool_start(zef, 'zef_ukfnmm_window', 1/3, 0);

if nargout == 0
    assignin('base', 'zef', zef);
end

end
