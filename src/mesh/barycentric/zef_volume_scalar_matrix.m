function M = zef_volume_scalar_matrix(nodes, tetra, scalar_field, weighting)
%ZEF_VOLUME_SCALAR_MATRIX  Volume mass matrix ∫ φ ψ_i ψ_j dV (F·F).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   F = P1 hat on tet vertices. φ is a per-tet scalar (T×1). Default
%   weighting 1 on every vertex pair; zef_volume_scalar_matrix_FF passes
%   [1/10 1/20]. NSE uses the FF wrapper for mass C and viscosity M.
%
%   M = zef_volume_scalar_matrix(nodes, tetra, scalar_field, weighting)
%
%   Inputs
%     nodes         - N×3.
%     tetra         - T×4.
%     scalar_field  - T×1, default ones. Multiplies every tet's contribution.
%     weighting     - scalar (used for both i=j and i≠j) or 1×2
%                     [w_diag w_off], default 1.
%
%   Output
%     M  - N×N sparse. sparse(tetra(:,i),tetra(:,j), φ V w); i≠j adds transpose.
%
%   See also zef_volume_scalar_matrix_FF, zef_barycentric_weighting.

N = size(nodes,1);
K = size(tetra,1);

if nargin < 4
    weighting = 1;
end

if nargin < 3
    scalar_field = ones(size(tetra,1),1);
end

if length(weighting)==1
    weight_param = weighting([1 1]);
else
    weight_param = weighting;
end

[~,det] = zef_volume_barycentric(nodes,tetra);
volume = abs(det)/6;

M = spalloc(N,N,0);

for i = 1 : 4
    for j = i : 4

        if i == j
            entry_vec = volume*weight_param(1);
        else
            entry_vec = volume*weight_param(2);
        end
        M_part = sparse(tetra(:,i),tetra(:,j),scalar_field.*entry_vec,N,N);

        if i == j
            M = M + M_part;
        else
            M = M + M_part;
            M = M + M_part';
        end

    end
end

end
