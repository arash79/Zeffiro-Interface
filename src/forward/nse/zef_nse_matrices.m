function [nse_mat] = zef_nse_matrices(nodes,tetra,rho,mu)
%ZEF_NSE_MATRICES  Assemble barycentric NSE operator matrices on a tetra mesh.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Constructs mass, stiffness, and convection-related sparse matrices from
%   nodal coordinates, tetra connectivity, mass density rho, and viscosity mu
%   for use in zef_nse_iteration and related solvers.
%
%   [nse_mat] = zef_nse_matrices(nodes, tetra, rho, mu)
%
%   Input
%     nodes - [n × 3] metres (callers divide mm by 1000 first)
%     tetra - [n_tet × 4]
%     rho   - [n_tet × 1] mass density
%     mu    - [n_tet × 1] viscosity
%
%   Output nse_mat fields: M, F mass; L_ij viscous GG; Q_i divergence FG;
%   B1_* / B2 surface traction; N row-normalized node adjacency.
%
%   See also zef_nse_iteration, zef_volume_barycentric.

nse_mat.M = zef_volume_scalar_matrix_FF(nodes,tetra,rho);

% Viscous stiffness blocks L_ij = ∫ μ ∂_i φ · ∂_j ψ (barycentric GG).
nse_mat.L_11 = zef_volume_scalar_matrix_GG(nodes,tetra,1,1,mu);
nse_mat.L_22 = zef_volume_scalar_matrix_GG(nodes,tetra,2,2,mu);
nse_mat.L_33 = zef_volume_scalar_matrix_GG(nodes,tetra,3,3,mu);
nse_mat.L_12 = zef_volume_scalar_matrix_GG(nodes,tetra,1,2,mu);
nse_mat.L_13 = zef_volume_scalar_matrix_GG(nodes,tetra,1,3,mu);
nse_mat.L_23 = zef_volume_scalar_matrix_GG(nodes,tetra,2,3,mu);

% Divergence / pressure-gradient blocks Q_i = ∫ φ ∂_i ψ (FG).
nse_mat.Q_1 = zef_volume_scalar_matrix_FG(nodes,tetra,1,ones(size(rho)));
nse_mat.Q_2 = zef_volume_scalar_matrix_FG(nodes,tetra,2,ones(size(rho)));
nse_mat.Q_3 = zef_volume_scalar_matrix_FG(nodes,tetra,3,ones(size(rho)));

nse_mat.F = zef_volume_scalar_matrix_FF(nodes,tetra,rho);

% Surface traction / normal-flux blocks (n and Dn mass on the free boundary).
nse_mat.B1_1 = zef_surface_scalar_matrix_n(nodes,tetra,1);
nse_mat.B1_2 = zef_surface_scalar_matrix_n(nodes,tetra,2);
nse_mat.B1_3 = zef_surface_scalar_matrix_n(nodes,tetra,3);

nse_mat.B2 = zef_surface_scalar_matrix_Dn(nodes,tetra,1,1);
nse_mat.B2 = nse_mat.B2 + zef_surface_scalar_matrix_Dn(nodes,tetra,2,2);
nse_mat.B2 = nse_mat.B2 + zef_surface_scalar_matrix_Dn(nodes,tetra,3,3);

[I,J,V] = find(nse_mat.M);

% N: row-normalized node adjacency (graph Laplacian smoother / averaging).
nse_mat.N = sparse(I,J,ones(size(V)));
diag_N = full(1./sum(nse_mat.N,2));
nse_mat.N = spdiags(diag_N,0,size(nse_mat.N,1),size(nse_mat.N,2))*nse_mat.N;

end
