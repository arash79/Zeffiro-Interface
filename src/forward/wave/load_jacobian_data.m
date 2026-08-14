

function [u_data_mat, f_data_mat] = load_jacobian_data(path_data, data_name, torre_dir)
%LOAD_JACOBIAN_DATA  Load Born u/f matrices from torre_dir/<data_name>/point_*.mat.
%
%   Zeffiro Interface (GPU-ToRRe-3D wave module).
%   Copyright © 2021- Sampsa Pursiainen & GPU-ToRRe-3D Development Team
%   See: https://github.com/sampsapursiainen/GPU-Torre-3D
%
%   path_data is a 2-vector of point indices (u from first, f from second).
%
%   [u_data_mat, f_data_mat] = load_jacobian_data(path_data, data_name, torre_dir)
%
%   See also save_jacobian_data, load_jacobian_data_complex.




load([torre_dir '/' data_name '/point_' int2str(path_data(1)) '_data.mat'], 'u_data_mat');
load([torre_dir '/' data_name '/point_' int2str(path_data(2)) '_data.mat'], 'f_data_mat');

end
