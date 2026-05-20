%Copyright © 2021- Sampsa Pursiainen & GPU-ToRRe-3D Development Team
%See: https://github.com/sampsapursiainen/GPU-Torre-3D


function [u_data_mat, f_data_mat] = load_jacobian_data(path_data, data_name, torre_dir)
% --- Zeffiro documentation header ---
% load_jacobian_data — Load jacobian data.
%
% Purpose:
%   Load jacobian data.
%   Folder: Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.
%
% Inputs:
%   path_data
%   data_name
%   torre_dir
%
% Outputs:
%   u_data_mat
%   f_data_mat
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[u_data_mat, f_data_mat]] = load_jacobian_data(path_data, data_name, torre_dir)` with project root and `src` on the path.
% --- End Zeffiro documentation header


load([torre_dir '/' data_name '/point_' int2str(path_data(1)) '_data.mat'], 'u_data_mat');
load([torre_dir '/' data_name '/point_' int2str(path_data(2)) '_data.mat'], 'f_data_mat');

end
