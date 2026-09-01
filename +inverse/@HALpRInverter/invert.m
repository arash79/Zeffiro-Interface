function [z_vec, self] = invert(self, f_data, L, procFile, source_direction_mode, source_positions, opts)
%invert  HALpR MAP loop: L1_optimization (q=1) or weighted L2 IRLS (q=2) with gamma updates.
%
%   Zeffiro Interface.
%   Copyright © 2025- Joonas Lahtinen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from utilities.inverse.run_frame_loop. Related GUI tool is
%   Inverse tools → Standardized Hierarchical L1 MAP (zef_sl1_iteration),
%   which is not this class.
%
%   q=1: inner L1_optimization, then gamma = beta ./ (theta0 + |z|).
%   q=2: weighted L2 IRLS; optional Standardized T_scale from resolution
%   rows; gamma uses |z|^q. The IRLS scale is max(|f|)^2 (absolute peak;
%   upstream used algebraic max(f), which is not polarity-invariant). A
%   zero frame returns z = 0.
%
%   Inputs
%     f_data - n_sensors×1 frame (or a matrix if you call invert yourself).
%     L      - processed lead field.
%     procFile, source_direction_mode, source_positions - mode 1/2 selects
%     interleaved triplet energy; mode 3 uses per-column energy.
%     opts.use_gpu / normalize_data - GPU for inner solves; normalize unused.
%
%   Outputs
%     z_vec - n_dof×1 HALpR MAP estimate.

    arguments

        self (1,1) inverse.HALpRInverter

        f_data (:,:) {mustBeA(f_data,["double","gpuArray"])}

        L (:,:) {mustBeA(L,["double","gpuArray"])}

        procFile (1,1) struct

        source_direction_mode

        source_positions

        opts.use_gpu (1,1) logical = false

        opts.normalize_data (1,1) double = 1

    end

if self.number_of_frames <= 1
    h = zef_waitbar(0,'HALpR Reconstruction.');
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
q = double(self.q);
snr_val = self.signal_to_noise_ratio;
std_lhood = 10^(-snr_val/20);

if estimation_type == 1
    StartTAG = 'HALpR IAS';
elseif estimation_type == 2
    StartTAG = 'HALpR EM';
elseif estimation_type == 3
    StartTAG = 'SHALpR';
end
self.tag = StartTAG;

S_mat = self.noise_cov;
if opts.use_gpu == 1 && gpuDeviceCount > 0
    L = gpuArray(L);
    S_mat = gpuArray(S_mat);
end

z_vec = ones(size(L,2),1);
f = f_data;
if opts.use_gpu == 1 && gpuDeviceCount > 0
    f = gpuArray(f_data);
end

if strcmp(hypermode,"Sensitivity weighted")
    col_energy = zef_leadfield_column_energy(L, source_direction_mode);
    switch q
        case 1
            c = sum(L.^2,1)*0.6366;
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
        case 2
            c = transpose((2*self.SNR_variable)./col_energy);
            beta = 1;
            theta0 = c;
    end
else
    beta = beta + 1/q;
    if estimation_type == 1
        beta = beta - 1;
    end
end

gamma = zeros(length(z_vec),1)+beta./theta0;
n = size(L,2);

if opts.use_gpu == 1 && gpuDeviceCount > 0
    z_vec = gather(z_vec);
end
if q == 1
    x_old = ones(n,1);
    nan_map_warned = false;
    for i = 1 : n_map_iterations
        z_vec = L1_optimization(L,std_lhood,f,gamma,x_old,n_L1_iterations,estimation_type);
        if sum(isnan(z_vec))>0
            if ~nan_map_warned
                warning('HALpRInverter:NaNInMapIteration', ...
                    'NaN in z_vec during HALpR MAP iterations (first at iteration %d of %d). Replacing NaNs with finite means.', i, n_map_iterations);
                nan_map_warned = true;
            end
            z_vec(isnan(z_vec))=mean(abs(z_vec(not(isnan(z_vec)))));
        end
        gamma = beta./(theta0+abs(z_vec));
        x_old = z_vec;
        if self.number_of_frames <= 1
            if i/n_map_iterations < 1
                zef_waitbar(i/n_map_iterations,h,[StartTAG,' MAP iteration.']);
            end
        end
    end
else
    for i = 1 : n_map_iterations
        if estimation_type == 3
            P = 1./gamma;
            L_aux2 = L.*P';
            R = L_aux2'/(L_aux2*L'+S_mat);
            R = sum(R.'.*L,1);
            T_scale = 1./sqrt(R)';
            clear R P L_aux2
        else
            T_scale = 1;
        end

        % Peak-amplitude scale. Upstream used max(f), the most positive
        % sample, so an all-negative frame collapsed the scale toward 0
        % and polarity flips were not odd in z. Use max(|f|).
        f_peak = max(abs(f(:)));
        if f_peak == 0
            z_vec = zeros(n, 1);
            gamma = beta./(theta0+abs(z_vec).^q);
            if self.number_of_frames <= 1
                zef_waitbar(i/n_map_iterations,h,[StartTAG,' MAP iteration.']);
            end
            continue
        end
        w = 1./(gamma*std_lhood^2*f_peak^2);
        if sum(isnan(z_vec))>0
            z_vec(isnan(z_vec)) = 0;
        end
        z_vec = (T_scale.*w).*(L'*((L*(w.*L') + eye(size(L,1)))\f));
        gamma = beta./(theta0+abs(z_vec).^q);
        if self.number_of_frames <= 1
            zef_waitbar(i/n_map_iterations,h,[StartTAG,' MAP iteration.']);
        end
    end
end

if opts.use_gpu == 1 && gpuDeviceCount > 0
    z_vec = gather(z_vec);
end

if self.number_of_frames <= 1
    zef_close_waitbar(h);
end
end
