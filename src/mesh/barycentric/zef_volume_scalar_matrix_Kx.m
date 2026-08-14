function M = zef_volume_scalar_matrix_Kx(nodes, tetra, h, x, u_field, volume, b_coord)
%ZEF_VOLUME_SCALAR_MATRIX_KX  Unfinished K-type operator (does not assign M).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Intended to assemble from barycentric coordinate h and nodal x. The
%   loops write entry_vec only; b_cood_h is a typo for b_coord_h. u_field
%   is unused. No first-party caller — do not use.
%
%   M = zef_volume_scalar_matrix_Kx(nodes, tetra, h, x, u_field, volume, b_coord)
%
%   See also zef_volume_barycentric.

det = [];

if nargin < 6
    for i = 1:4
        [b_coord,det] = zef_volume_barycentric(nodes,tetra,h);
        volume = abs(det)/6;
        b_coord_h{i} = b_coord(:,h);

        if h > 1
            [b_coord,~] = zef_volume_barycentric(nodes,tetra,h,det);
            volume = abs(det)/6;
            b_coord_h{i} = b_coord(:,h);
        end
    end
end

weight_param = zef_barycentric_weighting('FF');
b_coord_h = b_coord(:,h);

for i = 1 : 4
    for j = 1 : 4
        if i == j
            entry_vec = b_cood_h{i}.*volume*weight_param(1).*x(tetra(:,j));
        else
            entry_vec = b_cood_h{i}.*volume*weight_param(2).*x(tetra(:,j));
        end
    end
end

end
