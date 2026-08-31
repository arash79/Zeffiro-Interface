function [z_vec, self] = invert(self, f, L, procFile, source_direction_mode, source_positions, opts)
%invert  One-frame dSPM, sLORETA, 3D sLORETA, or SBL reconstruction.
%
%   Zeffiro Interface.
%   Copyright © 2025- Joonas Lahtinen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called once per time frame by utilities.inverse.run_frame_loop after
%   initialize / precompute. Inverse-tools → Classical Sparse Methods uses
%   zef_CSM_iteration instead of this method.
%
%   dSPM: z = d .* (P*f) with d_i = 1/sqrt((P S P')_ii),
%   S = (10^(-SNR/20)^2 / theta0) I. sLORETA: extra /sqrt(theta0) and
%   d from diag(P L). sLORETA 3D: per-source 3×3 G^{-1/2} (G = P_i L_i); when
%   source_direction_mode==2, constrained nodes (procFile.s_ind_4) get a
%   scalar scale and free nodes get the 3×3 block. SBL: iterative gamma
%   from whitened data covariance (cov(f') — one frame is rank-deficient
%   and is ridge-stabilized).
%
%   [z_vec, self] = invert(self, f, L, procFile, source_direction_mode, ...
%       source_positions, opts)
%
%   Inputs
%     self  - CSMInverter. method_type is "dSPM"|"sLORETA"|"sLORETA 3D"|"SBL"
%             (default "dSPM"). Uses theta0, signal_to_noise_ratio,
%             precomputed_P / precomputed_d / precomputed_Minv when precompute ran.
%     f     - n_sensors×1 frame from zef_getTimeStepClassObj (filtered).
%     L     - n_sensors×n_dof lead field after zef_processLeadfields.
%             Cartesian layout is [x-block, y-block, z-block], each of
%             length n_interp = numel(procFile.s_ind_0).
%     procFile - from zef_processLeadfields: s_ind_0 (all interpolated
%             sources), s_ind_4 (constrained / normal-locked indices).
%             Required for sLORETA 3D; unused for dSPM/sLORETA/SBL.
%     source_direction_mode - 1 Cartesian, 2 Normal, 3 Basis. Only the
%             sLORETA 3D branch switches on == 2.
%     source_positions - unused in this method (kept for the common
%             invert signature).
%     opts.use_gpu - from zef.use_gpu. Moves S/P to gpuArray when a device
%             exists; result is gathered.
%     opts.normalize_data - from zef.normalize_data; unused here.
%
%   Outputs
%     z_vec - n_dof×1 reconstruction for this frame.
%     self  - unchanged except waitbar lifecycle.

    arguments

        self (1,1) inverse.CSMInverter

        f (:,1) {mustBeA(f,["double","gpuArray"])}

        L (:,:) {mustBeA(L,["double","gpuArray"])}

        procFile (1,1) struct

        source_direction_mode

        source_positions

        opts.use_gpu (1,1) logical = false

        opts.normalize_data (1,1) double = 1

    end

    % Nested waitbar: dSPM / SBL keep the historical 1-frame figure.
    % sLORETA and sLORETA 3D skip it — creating the uifigure dominates the
    % solve, and utilities.inverse.run_frame_loop already reports frame progress.
    h = [];
    if self.number_of_frames <= 1 && ~ismember(self.method_type, ["sLORETA", "sLORETA 3D"])
        h = zef_waitbar(0,'CSM Reconstruction.');
        cleanup_fn = @(wb) close(wb);
        cleanup_obj = onCleanup(@() cleanup_fn(h));
    end

    % Get needed parameters from self and others.

    std_lhood = 10^(-self.signal_to_noise_ratio/20);
    n_interp = length(procFile.s_ind_0);

    % Then start inverting.

    theta0 = self.theta0;

    % The caches are only valid for the lead field and the method_type /
    % theta0 / SNR they were built with. Dropping them here keeps a settings
    % change after precompute from silently mixing an old P with a new
    % /sqrt(theta0) scaling, or from reusing the dSPM standardization vector
    % 1/sqrt((P S P')_ii) where sLORETA needs 1/sqrt((P L)_ii).
    if ~isempty(self.precomputed_P) ...
            && ~isequaln(self.precomputed_cache_key, self.cacheKey(L))
        self.precomputed_P = [];
        self.precomputed_d = [];
        self.precomputed_Minv = [];
        self.precomputed_cache_key = struct([]);
    end

    if ismember(self.method_type, ["dSPM" ; "sLORETA" ; "sLORETA 3D"])

        if isempty(self.precomputed_P)
            S_mat = (std_lhood^2/theta0)*eye(size(L,1));
            if opts.use_gpu && gpuDeviceCount > 0
                S_mat = gpuArray(S_mat);
            end
            P = L'/(L*L'+S_mat);
        else
            P = self.precomputed_P;
            if self.method_type == "dSPM"
                S_mat = (std_lhood^2/theta0)*eye(size(L,1), 'like', L);
            end
        end

        if self.method_type == "dSPM"

            if isempty(self.precomputed_d)
                d = 1./sqrt(sum(((P*S_mat).*P),2));
            else
                d = self.precomputed_d;
            end
    % dSPM: z_i = P_i f / sqrt((P S P')_ii)  (noise-normalized MNE)
            z_vec = d.*P*f;

        elseif self.method_type == "sLORETA"

            %__ sLORETA __
            if isempty(self.precomputed_d)
                d = 1./sqrt(sum(P.'.*L,1))';
            else
                d = self.precomputed_d;
            end
            % sLORETA: extra /sqrt(θ₀) so the resolution matrix is identity at each source
            z_vec = d.*(P*f)/sqrt(theta0);

        else

            z_vec = P * f;

            if opts.use_gpu && gpuDeviceCount > 0
                P = gather(P);
                L = gather(L);
                z_vec = gather(z_vec);
            end

            if source_direction_mode == 2

                r_ind = setdiff(1:n_interp,procFile.s_ind_4);
                [sx, sy, sz] = zef_interleaved_source_columns(procFile.s_ind_4);
                surf_ind = [sx; sy; sz];
                M = 1./sqrt(sum(P(surf_ind,:).'.*L(:,surf_ind),1))';
                z_vec(surf_ind) = M.*z_vec(surf_ind);
                z_vec = i_sloreta3d_apply(z_vec, P, L, n_interp, r_ind, self.precomputed_Minv);

            else

                z_vec = i_sloreta3d_apply(z_vec, P, L, n_interp, 1:n_interp, self.precomputed_Minv);

            end % if

            z_vec = z_vec/sqrt(theta0);

        end % if

    elseif self.method_type == "SBL"

        S_mat = (std_lhood^2)*eye(size(L,1));

        if opts.use_gpu && gpuDeviceCount > 0
            S_mat = gpuArray(S_mat);
        end

        %__ Sparse Bayesian Learning: iterative gamma from whitened data covariance __
        n_iter = self.SBL_number_of_iterations;
        C_data = cov(f');

        if det(C_data) < eps
            C_data = C_data + 0.05*trace(C_data)*eye(size(C_data,1))/size(C_data,1);
        end

        inv_sqrt_C = inv(sqrtm(gather(C_data)));
        gamma = ones(size(L,2),1);
        const = zeros(size(L,2),1);

        if opts.use_gpu & gpuDeviceCount > 0
            const = gather(const);
            L = gather(L);
        end

        for i = 1:size(L,2)
            const(i) = 1/(rank(L(:,i)*L(:,i)')*size(f,2));
        end

        if opts.use_gpu && gpuDeviceCount > 0
            const = gpuArray(const);
            gamma = gpuArray(gamma);
            L = gpuArray(L);
        end

        for i = 1:n_iter
            f_aux = inv_sqrt_C*f;
            L_aux = inv_sqrt_C*L;
            gamma = const.*gamma.*sum((L_aux'*f_aux).^2,2)./(size(L,2)-gamma.*sum(L_aux.^2,1)');
            C_data = L*(gamma.*L')+S_mat;
            inv_sqrt_C = inv(sqrtm(gather(C_data)));
        end

        z_vec = real(gamma.*(L'*(C_data\f)));

    end

    if opts.use_gpu && gpuDeviceCount > 0
        z_vec = gather(z_vec);
    end

end % function

function z_vec = i_sloreta3d_apply(z_vec, P, L, n, src_inds, Minv_all)
src_inds = src_inds(:);
if isempty(src_inds)
    return
end
if ~isempty(Minv_all) && size(Minv_all, 1) == 3 && size(Minv_all, 3) == n
    Minv = Minv_all(:, :, src_inds);
else
    Minv = zef_sloreta3d_build_minv(P, L, src_inds);
end
[ix, iy, iz] = zef_interleaved_source_columns(src_inds);
ns = numel(src_inds);
z3 = zeros(3, 1, ns);
z3(1, 1, :) = z_vec(ix);
z3(2, 1, :) = z_vec(iy);
z3(3, 1, :) = z_vec(iz);
z3 = pagemtimes(Minv, z3);
z_vec(ix) = z3(1, 1, :);
z_vec(iy) = z3(2, 1, :);
z_vec(iz) = z3(3, 1, :);
end
