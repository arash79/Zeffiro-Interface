function [x,y,z,D] = zef_3by3_solver(a,b,c,d,D)
%ZEF_3BY3_SOLVER  Batched Cramer rule for T independent 3×3 systems.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Each row is one matrix with columns a(t,:).', b(t,:).', c(t,:).'.
%   Used by zef_volume_barycentric (∇ψ), zef_source_tetra (barycentric
%   locate), and zef_inflate_surfaces (ray–triangle).
%
%   [x, y, z, D] = zef_3by3_solver(a, b, c)           % D only; x,y,z = []
%   [x, y, z, D] = zef_3by3_solver(a, b, c, d)        % also solve M λ = d
%   [x, y, z]    = zef_3by3_solver(a, b, c, d, D)     % reuse D
%
%   Inputs
%     a, b, c - T×3, the three columns of M (or the three edges).
%     d       - T×3 right-hand side (optional). If omitted, only D is
%               computed (nargin < 4 after D's optional 5th slot).
%     D       - T×1 det(M) from a prior call (optional, nargin>=5).
%
%   Outputs
%     x, y, z - T×1, λ = M^{-1} d when d is given.
%     D       - T×1 det([a b c]) with columns as rows of a,b,c.
%
%   See also zef_volume_barycentric.

x = [];
y = [];
z = [];

if nargin < 5

    D = a(:,1).*(b(:,2).*c(:,3) - b(:,3).*c(:,2));
    D = D - b(:,1).*(a(:,2).*c(:,3) - a(:,3).*c(:,2));
    D = D + c(:,1).*(a(:,2).*b(:,3) - a(:,3).*b(:,2));

end

if nargin > 3

    D_x =  d(:,1).*(b(:,2).*c(:,3) - b(:,3).*c(:,2));
    D_x = D_x   - b(:,1).*(d(:,2).*c(:,3) - d(:,3).*c(:,2));
    D_x = D_x   + c(:,1).*(d(:,2).*b(:,3) - d(:,3).*b(:,2));

    D_y = a(:,1).*(d(:,2).*c(:,3) - d(:,3).*c(:,2));
    D_y = D_y - d(:,1).*(a(:,2).*c(:,3) - a(:,3).*c(:,2));
    D_y = D_y + c(:,1).*(a(:,2).*d(:,3) - a(:,3).*d(:,2));

    D_z = a(:,1).*(b(:,2).*d(:,3) - b(:,3).*d(:,2));
    D_z = D_z - b(:,1).*(a(:,2).*d(:,3) - a(:,3).*d(:,2));
    D_z = D_z + d(:,1).*(a(:,2).*b(:,3) - a(:,3).*b(:,2));

    x = D_x./D;
    y = D_y./D;
    z = D_z./D;

end

end
