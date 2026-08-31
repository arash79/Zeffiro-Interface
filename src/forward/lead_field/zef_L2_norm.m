function norm = zef_L2_norm(arr, dim)
%ZEF_L2_NORM  Euclidean norm of rows (or of the whole array).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   n = zef_L2_norm(arr)        % sqrt(sum(arr.^2,'all'))
%   n = zef_L2_norm(arr, dim)   % sqrt(sum(arr.^2, dim))  — uses arr.^2, not abs
%
%   Interpolation (PBO/MPO/St. Venant) passes dim=2 for n×3 coordinate
%   rows. Note: two-arg form does not wrap abs, unlike a true L2 of
%   complex data.
if nargin == 2
    norm = sqrt(sum(arr.^2, dim));
else
    norm = sqrt(sum(arr.^2, 'all'));
end

end
