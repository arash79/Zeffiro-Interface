function [d] = zef_determinant(a,b,c,varargin)
%ZEF_DETERMINANT  Vectorized 3-by-3 determinant of columns a, b, c.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Scalar triple product det([a b c]) for many rows at once. Used by
%   zef_attach_sensors_volume to form barycentric coordinates of a point
%   sensor inside a tet (lambda_i = det of the three opposite edges /
%   det of the tet edges). No other first-party callers.
%
%   d = zef_determinant(a, b, c)
%   d = zef_determinant(a, b, c, det_dir)
%
%   Inputs
%     a, b, c  - 3-vectors stacked as n-by-3 (default) or 3-by-n.
%     det_dir  - optional; 1 means 3-by-n (index as a(1,:), a(2,:), a(3,:));
%                any other value, including the default 2, means n-by-3.
%
%   Output
%     d  - n-by-1 (or 1-by-n if det_dir==1) signed triple products.
%
%   See also zef_attach_sensors_volume.
det_dir = 2;
if not(isempty(varargin))
    det_dir = varargin{1};
end

if det_dir == 1;
    % 3-by-n: each column is one vector.
    d = a(1,:).*(b(2,:).*c(3,:) - c(2,:).*b(3,:)) - b(1,:).*(a(2,:).*c(3,:) - c(2,:).*a(3,:)) +  c(1,:).*(a(2,:).*b(3,:) - b(2,:).*a(3,:));
else
    d = a(:,1).*(b(:,2).*c(:,3) - c(:,2).*b(:,3)) - b(:,1).*(a(:,2).*c(:,3) - c(:,2).*a(:,3)) +  c(:,1).*(a(:,2).*b(:,3) - b(:,2).*a(:,3));
end

end
