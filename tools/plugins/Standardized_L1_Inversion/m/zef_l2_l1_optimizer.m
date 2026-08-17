function x = zef_l2_l1_optimizer(L, y, reg_param, options)
%ZEF_L2_L1_OPTIMIZER  quadprog L2-L1 (Lasso) inner step for sL1.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   x = zef_l2_l1_optimizer(L, y, reg_param, options)
%
%   Called from zef_sl1_iteration. quadprog on the lifted [source; |source|]
%   variable; returns the source half. No zef I/O.
%
%   Inputs
%     L         - lead field
%     y         - measurement
%     reg_param - L1 weights (std_lhood^2 ./ theta)
%     options   - quadprog options (interior-point-convex)
%
%   Output
%     x - source coefficients (first size(L,2) entries of the QP solution)
%
%   See also zef_sl1_iteration.

% Lifted Lasso: x = [z; t] with t ≥ |z| componentwise.
% Quadratic term is only on z (H = blkdiag(L'L, 0)); linear term is
% -L'y on z and the L1 weights on t. Constraints:
%   z - t ≤ 0,  -z + t ≤ 0  (i.e. t ≥ |z|),  -t ≤ 0.
H = [ L'*L zeros(size(L,2), size(L,2)) ; zeros(size(L,2), 2*size(L,2)) ];
f = [ - L'*y ; reg_param ];

A = [ eye(size(L,2)) -eye(size(L,2)); -eye(size(L,2)) eye(size(L,2)); zeros(size(L,2)) -eye(size(L,2))];
b = [ zeros(3*size(L,2),1) ];

x = quadprog(H, f, A, b, [], [], [], [], [], options);
x = x(1:size(L,2));

end
