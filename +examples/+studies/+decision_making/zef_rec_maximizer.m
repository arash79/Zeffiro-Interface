function max_point = zef_rec_maximizer(rec_arr, s_pos)
%
% zef_rec_maximizer - Find position of maximum-magnitude dipole in reconstruction.
%
% Inputs:
%   rec_arr  Reconstruction vector (3×n or length-3n), dipole moments [x;y;z] per source
%   s_pos    N×3 matrix of source positions
%
% Output:
%   max_point  1×3 position of the dipole with largest magnitude
%
    [~, max_ind] = max(sqrt(sum(reshape(rec_arr, 3, length(rec_arr(:))/3).^2)), [], 2);
    max_point = s_pos(max_ind, :);
end
