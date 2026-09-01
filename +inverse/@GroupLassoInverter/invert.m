function [z_vec, self] = invert(self, f_data, L, procFile, source_direction_mode, source_positions, opts)
%invert  Group LASSO MAP iterations: LG_optimization with updating gamma = beta./(theta0+zL2).
%
%   Zeffiro Interface.
%   Copyright © 2025- Joonas Lahtinen and Alexandra Koulouri
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from utilities.inverse.run_frame_loop (f_data is still one
%   frame vector there). Inverse tools Lasso / EXP uses exp_iteration,
%   not this class.
%
%   Inner solver LG_optimization; hyperparameter
%   gamma = beta ./ (theta0 + zL2) from the current group norms.
%
%   Inputs
%     f_data - n_sensors×1 frame (or a matrix if you call invert yourself).
%     L      - processed lead field.
%     procFile, source_direction_mode, source_positions - unused here.
%     opts.use_gpu / normalize_data - GPU for inner solves; normalize unused.
%
%   Outputs
%     z_vec - n_dof×1 group-LASSO MAP estimate.

    arguments

        self (1,1) inverse.GroupLassoInverter

        f_data (:,:) {mustBeA(f_data,["double","gpuArray"])}

        L (:,:) {mustBeA(L,["double","gpuArray"])}

        procFile (1,1) struct

        source_direction_mode

        source_positions

        opts.use_gpu (1,1) logical = false

        opts.normalize_data (1,1) double = 1

    end

if self.number_of_frames <= 1
    h = zef_waitbar(0,'GroupLasso Reconstruction.');
    cleanup_fn = @zef_close_waitbar;
    cleanup_obj = onCleanup(@() cleanup_fn(h));
end

estimation_type = self.estimation_type;
if strcmp(estimation_type,"IAS")
    estimation_type = 1;
elseif strcmp(estimation_type,"EM")
    estimation_type = 2;
elseif strcmp(estimation_type,"Standardized")
    estimation_type = 3;
end
n_map_iterations = self.n_map_iterations;
n_L1_iterations = self.n_L1_iterations;
hypermode = self.hyperprior_mode;
beta = self.beta;
theta0 = self.theta0;
snr_val = self.signal_to_noise_ratio;
std_lhood = 10^(-snr_val/20);

if estimation_type == 1
    StartTAG = 'Group Lasso IAS';
elseif estimation_type == 2
    StartTAG = 'Group Lasso EM';
elseif estimation_type == 3
    StartTAG = 'Standardized Group Lasso';
end
self.tag = StartTAG;

use_gpu_device = opts.use_gpu == 1 && gpuDeviceCount > 0;
if use_gpu_device
    L = gpuArray(L);
end

z_vec = ones(size(L,2),1);
f = f_data;
if use_gpu_device
    f = gpuArray(f_data);
end

if ~ismember(source_direction_mode, [1, 2]) || mod(size(L,2), 3) ~= 0
    error("GroupLassoInverter:LeadFieldNotTriplets", ...
        "Group Lasso groups Cartesian xyz triples (source_direction_mode 1 or 2); L has %d columns and mode %g.", ...
        size(L,2), source_direction_mode);
end

if strcmp(hypermode,"Sensitivity weighted")
    L_sq = sum(L.^2,1);
    c = L_sq*0.6366;
    col_energy = zef_leadfield_column_energy(L, source_direction_mode);
    sens = 2*col_energy./self.SNR_variable;
    root = sqrt(c+8*sens);
    sqrtc = sqrt(c);
    ind = 3*sqrtc-root>0;
    n_ind = not(ind);
    beta(ind) = 4*sqrtc(ind)./(3*sqrtc(ind)-root(ind));
    beta(n_ind) = 4*sqrtc(n_ind)./(root(n_ind)+3*sqrtc(n_ind));
    theta0 = (beta./sqrtc)';
    theta0(beta<2) = sqrt(3.75./sens)';
    beta(beta<2) = 3.5;
    beta = beta';
else
    beta = beta + 1;
    if estimation_type == 1
        beta = beta - 1;
    end
end

gamma = zeros(length(z_vec),1)+beta./theta0;
n = size(L,2);
sigma_lg = std_lhood;
L_map = L;
f_map = f;
if sigma_lg ~= 1
    L_map = (1/sigma_lg)*L;
    f_map = (1/sigma_lg)*f;
    sigma_lg = 1;
end

x_old = ones(n,1);
nan_map_warned = false;
for i = 1 : n_map_iterations
    z_vec = LG_optimization(L_map,sigma_lg,f_map,gamma,x_old,n_L1_iterations,estimation_type);
    if sum(isnan(z_vec))>0
        finite_z = z_vec(not(isnan(z_vec)));
        if isempty(finite_z)
            error("GroupLassoInverter:AllNaN", ...
                "Group Lasso MAP iteration %d of %d produced an all-NaN source vector.", i, n_map_iterations);
        end
        if ~nan_map_warned
            warning("GroupLassoInverter:NaNInMapIteration", ...
                "NaN in z_vec during Group Lasso MAP iterations (first at iteration %d of %d). Replacing NaNs with the mean of finite |z|.", i, n_map_iterations);
            nan_map_warned = true;
        end
        z_vec(isnan(z_vec))=mean(abs(finite_z));
    end
    zL2 = repelem(sqrt(sum(reshape(z_vec.^2,3,[]))),3)';
    gamma = beta./(theta0+zL2);
    x_old = z_vec;
    if self.number_of_frames <= 1
        zef_waitbar(i/n_map_iterations,h,[StartTAG,' MAP iteration.']);
    end
end

if use_gpu_device
    z_vec = gather(z_vec);
end

if self.number_of_frames <= 1
    zef_close_waitbar(h);
end
end
