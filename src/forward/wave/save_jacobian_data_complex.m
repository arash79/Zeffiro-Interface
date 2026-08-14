

function save_jacobian_data_complex(aux_mat_cos, aux_mat_sin, ind_vec, torre_dir)
%SAVE_JACOBIAN_DATA_COMPLEX  Write cos/sin Jacobian blocks aux_mat_i_j.mat.
%
%   Zeffiro Interface (GPU-ToRRe-3D wave module).
%   Copyright © 2021- Sampsa Pursiainen & GPU-ToRRe-3D Development Team
%   See: https://github.com/sampsapursiainen/GPU-Torre-3D
%
%   save_jacobian_data_complex(aux_mat_cos, aux_mat_sin, ind_vec, torre_dir)
%
%   See also save_jacobian_data, load_jacobian_data_complex.




save([torre_dir '/system_data/aux_mat_' int2str(ind_vec(1)) '_' int2str(ind_vec(2)) '.mat'],'aux_mat_cos', 'aux_mat_sin')

end
