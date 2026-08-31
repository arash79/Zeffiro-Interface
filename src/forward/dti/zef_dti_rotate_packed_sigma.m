function sigma6 = zef_dti_rotate_packed_sigma(sigma6, R)
%ZEF_DTI_ROTATE_PACKED_SIGMA  σ_mesh = R σ_voxel R' for packed 6-vectors.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Packed layout is [σ11 σ22 σ33 σ12 σ13 σ23] per row, matching
%   zef.sigma(:,3:8) and the stiffness assembler.
%
%   sigma6 = zef_dti_rotate_packed_sigma(sigma6, R)
%
%   See also zef_dti_polar_rotation, zef_stiffness_matrix.

if isempty(sigma6)
    return
end
R = double(R);
n = size(sigma6, 1);
S = zeros(3, 3, n);
S(1, 1, :) = double(sigma6(:, 1));
S(2, 2, :) = double(sigma6(:, 2));
S(3, 3, :) = double(sigma6(:, 3));
S(1, 2, :) = double(sigma6(:, 4));
S(2, 1, :) = double(sigma6(:, 4));
S(1, 3, :) = double(sigma6(:, 5));
S(3, 1, :) = double(sigma6(:, 5));
S(2, 3, :) = double(sigma6(:, 6));
S(3, 2, :) = double(sigma6(:, 6));
S2 = pagemtimes(pagemtimes(R, S), R');
out = zeros(n, 6);
out(:, 1) = S2(1, 1, :);
out(:, 2) = S2(2, 2, :);
out(:, 3) = S2(3, 3, :);
out(:, 4) = S2(1, 2, :);
out(:, 5) = S2(1, 3, :);
out(:, 6) = S2(2, 3, :);
if isa(sigma6, 'single')
    sigma6 = single(out);
else
    sigma6 = out;
end

end
