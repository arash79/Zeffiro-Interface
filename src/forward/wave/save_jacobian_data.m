

function save_jacobian_data(aux_mat, j, torre_dir)
%SAVE_JACOBIAN_DATA  Write aux_mat_j.mat under torre_dir/system_data.
%
%   Zeffiro Interface (GPU-ToRRe-3D wave module).
%   Copyright © 2021- Sampsa Pursiainen & GPU-ToRRe-3D Development Team
%   See: https://github.com/sampsapursiainen/GPU-Torre-3D
%
%   save_jacobian_data(aux_mat, j, torre_dir)
%
%   See also load_jacobian_data, save_jacobian_data_complex.




save([torre_dir '/system_data/aux_mat_' int2str(j)],'aux_mat')

end
