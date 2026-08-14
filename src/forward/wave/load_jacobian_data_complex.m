

function [u_data_mat_complex, f_data_mat_complex, rec_data_complex_receiver] = load_jacobian_data_complex(path_data, data_name, torre_dir)
%LOAD_JACOBIAN_DATA_COMPLEX  Load QAM I/Q Jacobian and receiver traces from disk.
%
%   Zeffiro Interface (GPU-ToRRe-3D wave module).
%   Copyright © 2021- Sampsa Pursiainen & GPU-ToRRe-3D Development Team
%   See: https://github.com/sampsapursiainen/GPU-Torre-3D
%
%   [u_data_mat_complex, f_data_mat_complex, rec_data_complex_receiver] = ...
%       load_jacobian_data_complex(path_data, data_name, torre_dir)
%
%   See also load_jacobian_data, save_jacobian_data_complex.




load([torre_dir '/' data_name '/point_' int2str(path_data(1)) '_data.mat'], 'u_data_mat','u_data_mat_quad');
load([torre_dir '/' data_name '/point_' int2str(path_data(2)) '_data.mat'], 'f_data_mat','f_data_mat_quad');
load([torre_dir '/' data_name '/point_' int2str(path_data(2)) '_data.mat'], 'rec_data','rec_data_quad');

rec_data_complex_receiver = rec_data(path_data(2),:) + i*rec_data_quad(path_data(2),:);
u_data_mat_complex = u_data_mat + i*u_data_mat_quad;
f_data_mat_complex = f_data_mat + i*f_data_mat_quad;

end
