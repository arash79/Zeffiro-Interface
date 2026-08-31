function T = zef_dti_as_column_affine(T)
%ZEF_DTI_AS_COLUMN_AFFINE  Homogeneous 4×4 in column-vector form.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   MATLAB niftiinfo / affine3d store T so that [x y z 1] = [u v w 1] * T
%   (translation in the last row). FreeSurfer register.dat / vox2ras use
%   p = T * [u; v; w; 1] (translation in the last column).
%
%   If the translation lives in row 4 rather than column 4, T is transposed.
%   Identity / pure linear maps are left unchanged.
%
%   T = zef_dti_as_column_affine(T)
%
%   See also zef_dti_tensor_interpolate_mesh_space.

if isempty(T) || ~isequal(size(T), [4 4])
    error('zef_dti_as_column_affine:InvalidT', 'T must be 4×4.');
end
T = double(T);
row_t = norm(T(4, 1:3));
col_t = norm(T(1:3, 4));
if row_t > col_t * 1.0000001 && row_t > 1e-15
    T = T';
end

end
