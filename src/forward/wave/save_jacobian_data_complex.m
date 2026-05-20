%Copyright © 2021- Sampsa Pursiainen & GPU-ToRRe-3D Development Team
%See: https://github.com/sampsapursiainen/GPU-Torre-3D


function save_jacobian_data_complex(aux_mat_cos, aux_mat_sin, ind_vec, torre_dir)
% --- Zeffiro documentation header ---
% save_jacobian_data_complex — Save jacobian data complex.
%
% Purpose:
%   Save jacobian data complex.
%   Folder: Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.
%
% Inputs:
%   aux_mat_cos
%   aux_mat_sin
%   ind_vec
%   torre_dir
%
% Outputs:
%   See function signature and code below.
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `save_jacobian_data_complex(aux_mat_cos, aux_mat_sin, ind_vec, torre_dir)` with project root and `src` on the path.
% --- End Zeffiro documentation header


save([torre_dir '/system_data/aux_mat_' int2str(ind_vec(1)) '_' int2str(ind_vec(2)) '.mat'],'aux_mat_cos', 'aux_mat_sin')

end
