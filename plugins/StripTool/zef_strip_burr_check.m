function [ok, notice] = zef_strip_burr_check(radius_mm, conductivity)
%ZEF_STRIP_BURR_CHECK  Accept a radius and a replacement conductivity.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Radius must be a finite millimetre value greater than 0. Conductivity
%   must be a finite S/m value greater than or equal to 0. Zero is
%   accepted and reported: it is not replaced by a small positive number.
%   Negative and non-finite values are rejected and left unchanged.
%
%   [ok, notice] = zef_strip_burr_check(radius_mm, conductivity)
%
%   See also zef_strip_apply_burr_holes.

ok = false;
notice = '';
if ~isscalar(radius_mm) || ~isnumeric(radius_mm) || ~isfinite(double(radius_mm)) ...
        || double(radius_mm) <= 0
    notice = 'Radius must be a finite number of millimetres greater than 0.';
    return
end
if ~isscalar(conductivity) || ~isnumeric(conductivity) ...
        || ~isfinite(double(conductivity)) || double(conductivity) < 0
    notice = ['Conductivity must be a finite number of S/m and at least 0. ' ...
        'The entered value was not replaced with another number.'];
    return
end
ok = true;
if double(conductivity) == 0
    notice = ['Conductivity 0 S/m is stored exactly. Those elements add nothing ' ...
        'to the stiffness matrix, which can make the FEM system singular.'];
end

end
