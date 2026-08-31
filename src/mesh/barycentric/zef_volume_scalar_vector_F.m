function v = zef_volume_scalar_vector_F(nodes, tetra, scalar_field)
%ZEF_VOLUME_SCALAR_VECTOR_F  Volume load ∫ φ ψ_i dV with weight 1/4 per vertex.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Exact for constant φ (four hats partition unity). NSE gravity loads
%   g_1..g_3 and volume weights w_1, c_vec, w_4.
%
%   v = zef_volume_scalar_vector_F(nodes, tetra, scalar_field)
%
%   See also zef_nse_poisson.

N = size(nodes,1);

if nargin < 3
    scalar_field = ones(size(tetra,1),1);
end

weight_param = 1/4;

[~,det] = zef_volume_barycentric(nodes,tetra);
volume = abs(det)/6;

v = zeros(N,1);

for i = 1 : 4

    v_part = sparse(tetra(:,i),ones(size(tetra,1),1),weight_param.*scalar_field.*volume,N,1);
    v = v + full(v_part);

end

end
