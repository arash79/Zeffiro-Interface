function L = zef_average_tes_dof_current(dof_ind, dof_count, R1, R2, R3)
%ZEF_AVERAGE_TES_DOF_CURRENT  Average TES current-density triplets per DOF.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   L = zef_average_tes_dof_current(dof_ind, dof_count, R1, R2, R3)
%
%   Several tetrahedra can share a TES DOF. Rows of R1/R2/R3 are the x/y/z
%   current-density blocks for each source tetra. The result is a 3*K3-by-L
%   matrix with interleaved Cartesian components, each DOF divided by its
%   occupancy. The TES FEM transposes this after assembly.
%
%   See also zef_lead_field_tes_fem, zef_decompose_dof_space.

K = numel(dof_ind);
K3 = numel(dof_count);
Lch = size(R1, 2);
L = zeros(3 * K3, Lch);
S_dof = sparse(dof_ind(:), (1:K)', 1, K3, K);
dc = dof_count(:);
L(1:3:end, :) = (S_dof * R1) ./ dc;
L(2:3:end, :) = (S_dof * R2) ./ dc;
L(3:3:end, :) = (S_dof * R3) ./ dc;

end
