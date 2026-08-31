function R = zef_dti_polar_rotation(A)
%ZEF_DTI_POLAR_ROTATION  Orthogonal factor of a 3×3 linear map (polar).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   svd(A) = W S V' → R = W V'. R'R = I. det(R) may be −1 (axis flip in
%   the NIfTI qform); that reflection is kept so voxel-index handedness
%   is preserved. Scale in S is discarded: conductivity eigenvalues must
%   not be multiplied by voxel-size².
%
%   R = zef_dti_polar_rotation(A)
%
%   See also zef_dti_rotate_packed_sigma.

A = double(A);
if ~isequal(size(A), [3 3])
    error('zef_dti_polar_rotation:InvalidA', 'A must be 3×3.');
end
if rcond(A) < 1e-12
    error('zef_dti_polar_rotation:Singular', ...
        'Linear part of the mesh↔voxel map is singular.');
end
[W, ~, V] = svd(A);
R = W * V';

end
