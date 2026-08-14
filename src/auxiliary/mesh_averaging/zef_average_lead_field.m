%ZEF_AVERAGE_LEAD_FIELD  Lab script: coarsen zef.L onto a lattice (incomplete).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Needs workspace zef.L, zef.source_positions, and source_count.
%   Calls zef_decompose_soure_space then accumulates columns into L_2.
%   The loop also reads undeclared L and L_tes and later divides L (not
%   L_2) by dof_count using M=n_sensors as if it were n_sources. Does not
%   write zef.L. One-off / unfinished mesh-averaging helper.
%
%   See also zef_decompose_soure_space.

L_1 = zef.L;
source_positions = zef.source_positions;

[dof_ind, dof_count, dof_positions] = zef_decompose_soure_space(source_count, zef.source_positions);

M = size(L_1,1);
N = size(dof_positions,1);
L_2 = zeros(M,N);

K = size(source_positions,1);

for i = 1 : K
    L_2(:,3*(dof_ind(i)-1)+1) =  L(:,3*(dof_ind(i)-1)+1) + L_1(:,i);
    L_2(:,3*(dof_ind(i)-1)+2) =  L(:,3*(dof_ind(i)-1)+2) + L_1(:,i+1);
    L_2(:,3*(dof_ind(i)-1)+3) =  L_tes(:,3*(dof_ind(i)-1)+3) + L_1(:,i+2);
end

for i = 1 : M
    L(:,3*(i-1)+1) = L(:,3*(i-1)+1)/dof_count(i);
    L(:,3*(i-1)+2) = L(:,3*(i-1)+2)/dof_count(i);
    L(:,3*(i-1)+3) = L(:,3*(i-1)+3)/dof_count(i);
end
