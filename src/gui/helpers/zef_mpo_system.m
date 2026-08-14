function out_coeff_sys = zef_mpo_system( ...
    arg_locs, ...
    arg_dirs, ...
    arg_interp_locs, ...
    arg_interp_loc_row, ...
    arg_n_of_coeffs ...
    )
%ZEF_MPO_SYSTEM  Mean position/orientation (MPO) weights for one source.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Whitney / H(div) interpolation when optimization_system_type is 'mpo'.
%
%   out_coeff_sys = zef_mpo_system(locs, dirs, interp_locs, interp_row, n_coeff)
%
%   Target x* is interp_locs(interp_row,:). Position differences
%   (locs − x*) are scaled by 1/(2 max ‖Δx‖) into moments. M stacks
%   dirs' and dirs' times diag(moment_x/y/z). b is [I_3; zeros] and
%   coefficients are lsqminnorm(M, b) (n_coeff×3). Callers keep the
%   first n_coeff rows as dipole weights.
%
%   See also zef_pbo_system, zef_whitney_interpolation.


arguments
    arg_locs (:,3) double
    arg_dirs (:,3) double
    arg_interp_locs (:,3) double
    arg_interp_loc_row (:,1) double { mustBePositive, mustBeInteger }
    arg_n_of_coeffs (1,1) double { mustBePositive, mustBeInteger }
end

% Distances between interpolation and dipole positions.

interp_pos = arg_interp_locs(arg_interp_loc_row, :);

interp_pos = repmat(interp_pos, arg_n_of_coeffs, 1);

pos_diffs = arg_locs - interp_pos;

dists = zef_L2_norm(pos_diffs, 2);

% Reference distance for scaling purposes: twice the length of longest
% edge, although here distances do not represent edges…

scaling_factor = 1 / max(dists) / 2;

% Moments whose components will be inserted into the P-matrices.

moments = scaling_factor * pos_diffs;

moment_x = moments(:,1);
moment_y = moments(:,2);
moment_z = moments(:,3);

% Generate position difference matrices.

Px = diag(moment_x);
Py = diag(moment_y);
Pz = diag(moment_z);

% Generate the MPO matrix M with with the position difference matrices and
% direction matrices.

M = [
    arg_dirs' ;
    arg_dirs' * Px ;
    arg_dirs' * Py ;
    arg_dirs' * Pz ;
    ];

% The vector b, against which M will be inverted, with a Cartesian basis
% assumption.

zero_block = zeros(arg_n_of_coeffs-1,3);

basis = eye(3);

b = [ basis ; zero_block ];

% Calculate interpolation coefficients (lsqminnorm is advertised as being
% more efficient than pinv).

out_coeff_sys = lsqminnorm(M, b);

end
