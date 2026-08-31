function out_coeff_sys = zef_pbo_system( ...
    arg_locs, ...
    arg_dirs, ...
    arg_interp_locs, ...
    arg_interp_loc_row, ...
    arg_n_of_coeffs ...
    )
%ZEF_PBO_SYSTEM  Position-based optimization (PBO) weights for one source.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Whitney / H(div) interpolation when optimization_system_type is 'pbo'.
%
%   out_coeff_sys = zef_pbo_system(locs, dirs, interp_locs, interp_row, n_coeff)
%
%   locs, dirs  - n_coeff×3 dipole positions and unit directions.
%   interp_locs - barycentra; row interp_row is the target x*.
%
%   Saddle-point system (n_coeff+3)×(n_coeff+3) for each of 3 Cartesian
%   right-hand sides:
%
%     [ diag(||x_k − x*||)   dirs ]
%     [ dirs'                  0  ]  [λ; μ] = [0; I_3]
%
%   Distances from zef_L2_norm. Output is (n_coeff+3)×3; callers keep
%   rows 1:n_coeff as the dipole weights (three columns = e_x, e_y, e_z).
%
%   See also zef_mpo_system, zef_whitney_interpolation.


arguments
    arg_locs (:,3) double
    arg_dirs (:,3) double
    arg_interp_locs (:,3) double
    arg_interp_loc_row (:,1) double { mustBePositive, mustBeInteger }
    arg_n_of_coeffs (1,1) double { mustBePositive, mustBeInteger }
end

% PBO weigth coefficients from differences between barycentra
% (interpolation positions) and dipole positions.

interp_pos = arg_interp_locs(arg_interp_loc_row, :);

interp_pos = repmat(interp_pos, arg_n_of_coeffs, 1);

pos_diffs = arg_locs - interp_pos;

weight_coefs = zef_L2_norm(pos_diffs, 2);

% Position-based optimization matrix.

PBO_mat = [                     ...
    diag(weight_coefs) arg_dirs; ...
    arg_dirs' zeros(3,3)         ...
    ];

% Solve for Lagrangian multipliers to generate coefficient matrix.

out_coeff_sys = PBO_mat \ [zeros(arg_n_of_coeffs,3); eye(3)];

end
