function [z_vec, self] = invert(self, f, L, procFile, source_direction_mode, source_positions, opts)
%invert  Dipole-scan GoF map for one frame (cached or legacy per-source path).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from utilities.inverse.run_frame_loop. Inverse tools → Dipole
%   Scan uses zef_dipoleScan, not this method.
%
%   If precompute stored SVD pages, i_invert_cached applies them to the
%   whitened frame. Otherwise this file whitens f and L with noise_cov
%   (sqrtm) and scans procFile.s_ind_4 (fixed) then free sources. Free
%   orientation goodness-of-fit is scaled by the unit dipole direction
%   over sqrt(3).
%
%   Inputs
%     f, L - frame and processed lead field (columns a multiple of 3).
%     procFile.s_ind_0, .s_ind_4 - source index maps.
%     source_direction_mode, source_positions - unused here.
%     opts.use_gpu / normalize_data - gather at end; normalize unused.
%
%   Outputs
%     z_vec - n_dof×1 scan statistic (GoF) for this frame.
%     self  - unchanged caches.

    arguments

        self (1,1) inverse.DipoleScanInverter

        f (:,1) {mustBeA(f,["double","gpuArray"])}

        L (:,:) {mustBeA(L,["double","gpuArray"])}

        procFile (1,1) struct

        source_direction_mode

        source_positions

        opts.use_gpu (1,1) logical = false

        opts.normalize_data (1,1) double = 1

    end

    fixed_orientation_source_inds = procFile.s_ind_4;
    free_orientation_source_inds = setdiff(1:length(procFile.s_ind_0), procFile.s_ind_4);

    % The caches are only valid for the lead field, noise_cov and
    % regularization they were built from. The cached path never looks at the
    % L passed in, so a stale factorization would otherwise be applied to a
    % different model without any warning.
    if ~isempty(self.precomputed_L_w) ...
            && ~isequaln(self.precomputed_cache_key, self.cacheKey(L))
        self.precomputed_L_w = [];
        self.precomputed_whitening = [];
        self.precomputed_U_pages = [];
        self.precomputed_S_diag = [];
        self.precomputed_V_pages = [];
        self.precomputed_cache_key = struct([]);
    end

    % Fast path: if precompute(L) was called, all per-source SVDs and the
    % Mahalanobis whitening of L have been cached. Apply them in one batched
    % matrix multiply per frame. Skip the nested waitbar — the cached path
    % is a few milliseconds and run_frame_loop already reports frame progress.

    has_cache = ~isempty(self.precomputed_L_w) && ~isempty(self.precomputed_U_pages);
    if has_cache
        z_vec = i_invert_cached(self, f, fixed_orientation_source_inds, free_orientation_source_inds);
        return;
    end

    % Initialize waitbar with a cleanup object that automatically closes the
    % waitbar, if there is an interruption with Ctrl + C or when this function
    % exits. Only used by the legacy per-source path below.
    if self.number_of_frames <= 1
        h = zef_waitbar(0,'Dipole Scan reconstruction.');
        cleanup_fn = @zef_close_waitbar;
        cleanup_obj = onCleanup(@() cleanup_fn(h));
    end

    % Legacy per-call path: kept for back-compat when invert is called
    % without a preceding precompute (e.g. directly from user code).

    date_str = NaN;

    %Modify to compensate Mahlanobis distance used instead of L2-norm when
   %noise covariance exists
   Chalf = sqrtm(self.noise_cov);
   L = Chalf\L;
   f = Chalf\f;
   clear Chalf;

    free_orientation_source_num = length(free_orientation_source_inds);
    waitbar_update_freq = floor(free_orientation_source_num/10);
    data_norm_sqr = sum(f.^2);

    %Gather the lead field to make the script faster
    if opts.use_gpu && gpuDeviceCount > 0
        L = gather(L);
    end

    z_vec = zeros(size(L,2),1);
    
    % Then start inverting.

    %Compute fixed orientation cases first
    for i = 1:length(fixed_orientation_source_inds)
        LF = L(:,3*fixed_orientation_source_inds(i));
        switch self.method_type
            case "SVD"
                [U,S,V] = svd(LF,'econ');
                source_est = V*(S\(U'*f));

            case "Pseudoinverse"
                source_est = pinv(LF)*f;
        end

        %Recularization of the lead field
        if not(strcmp(self.reg_type,"None"))
            [U,S,V] = svd(LF,'econ');
            LF = U*(S+self.reg_parameter*eye(size(S)))*V';
        end

        %Set goodness of fit (GoF) measure result to reconstruction
        z_vec(3*fixed_orientation_source_inds(i)-[2,1,0]) = 1 - sum((f-LF*source_est).^2)/data_norm_sqr;

    end



    %Free orientation scanning
    for i = 1:length(free_orientation_source_inds)
        %------- Waitbar computations -------
        if self.number_of_frames <=1
            tic;
            time_val = toc;
            date_str = display_waitbar(h,i,free_orientation_source_num,waitbar_update_freq,date_str,time_val);
        end

        ind3D = 3*free_orientation_source_inds(i) - [2,1,0];
        LF = L(:,ind3D);

        %Recularization of the lead field
        if not(strcmp(self.reg_type,"None"))
            [U,S,V] = svd(LF,'econ');
            LF = U*(S+self.reg_parameter*eye(size(S)))*V';
        end

        switch self.method_type
            case "SVD"
                [U,S,V] = svd(LF,'econ');
                source_est = V*(S\(U'*f));

            case "Pseudoinverse"
                source_est = pinv(LF)*f;
        end
        
        %Set goodness of fit (GoF) measure result to reconstruction
        z_vec(ind3D) = 1 - sum((f-LF*source_est).^2)/data_norm_sqr;
        %set direction based on the source direction
        source_est = source_est/sqrt(sum(source_est.^2));
        %sqrt(s^2+s^2+s^2) = sqrt(3)*|s|
        z_vec(ind3D) = z_vec(ind3D).*source_est/sqrt(3);
    end

end % function

%%

function date_str = display_waitbar(h,index,max_iter,update_frequency,date_str,time_val)
if index > 1
    if mod(index,update_frequency) == update_frequency - 1
        date_str = char(datetime(datevec(now+(max_iter/(index-1) - 1)*time_val/86400)));
    end

    if mod(index,update_frequency) == 0
        zef_waitbar(index/max_iter,h,['Step ' int2str(index) ' of ' int2str(max_iter) '. Ready: ' date_str '.' ]);
    end
end

end

function z_vec = i_invert_cached(self, f, fixed_inds, free_inds)
%I_INVERT_CACHED Per-frame inversion that reuses precomputed factorisations.
%
% Mathematical equivalence with the legacy per-call branch above:
%
%   * Whitening (Chalf \ L, Chalf \ f) is applied once in precompute and
%     here we only whiten f via the cached whitening matrix.
%   * For free-orientation sources, both branches end up with
%       LF_eff = U * S_eff * V'   (S_eff = S + reg if reg_type ~= "None")
%       source_est = V * (S_eff \ (U' * f_w))
%       pot       = LF_eff * source_est = U * (U' * f_w)
%     because V'*V = I in the thin SVD. So gof = ||U' f_w||^2 / ||f_w||^2
%     and only source_est depends on the regularisation, exactly like the
%     legacy code (which reads source_est from the regularised SVD).
%   * For fixed-orientation sources LF is a single column. The legacy code
%     computes source_est from the *non-regularised* SVD (or pinv) and then
%     replaces LF with LF_eff = ((s+reg)/s) * LF before forming pot, which
%     gives the closed form
%       gof = (proj^2 / s^2) * c * (2 - c) / ||f_w||^2,  c = (s+reg)/s
%     used below. With reg = 0 (c = 1) this reduces to the standard
%     proj^2 / (s^2 * ||f_w||^2) goodness-of-fit.

f_w = self.precomputed_whitening * f;
data_norm_sqr = sum(f_w.^2);

n_total_cols = size(self.precomputed_L_w, 2);
z_vec = zeros(n_total_cols, 1);

if data_norm_sqr <= 0
    return;
end

% --- Fixed-orientation sources (single column of L per source). ---

if ~isempty(fixed_inds)
    fixed_inds = fixed_inds(:);
    L_fixed = self.precomputed_L_w(:, 3 * fixed_inds);
    LF_norm_sqr = sum(L_fixed.^2, 1).';
    proj = L_fixed.' * f_w;

    if strcmp(self.reg_type, "None")
        eff_factor = ones(size(LF_norm_sqr));
    else
        s_fixed = sqrt(LF_norm_sqr);
        eff_factor = (s_fixed + self.reg_parameter) ./ s_fixed;
    end

    safe_norm = LF_norm_sqr;
    safe_norm(safe_norm == 0) = 1;
    gof_fixed = (proj.^2 ./ safe_norm) .* eff_factor .* (2 - eff_factor) / data_norm_sqr;
    gof_fixed(LF_norm_sqr == 0) = 0;

    z_vec(3 * fixed_inds - 2) = gof_fixed;
    z_vec(3 * fixed_inds - 1) = gof_fixed;
    z_vec(3 * fixed_inds)     = gof_fixed;
end

% --- Free-orientation sources (3 columns of L per source, batched). ---

if isempty(free_inds)
    return;
end

free_inds = free_inds(:);
n_free = numel(free_inds);
n_sources = size(self.precomputed_U_pages, 3);

% Project onto every source page, then gather free columns. Slicing
% U_pages(:,:,free_inds) first would copy an n_ch×3×n_free array per frame.
alpha_3d = pagemtimes(self.precomputed_U_pages, 'transpose', f_w, 'none');
alpha_all = reshape(alpha_3d, 3, n_sources);
if n_free == n_sources
    alpha = alpha_all;
    S_free = self.precomputed_S_diag;
    V_free = self.precomputed_V_pages;
else
    alpha = alpha_all(:, free_inds);
    S_free = self.precomputed_S_diag(:, free_inds);
    V_free = self.precomputed_V_pages(:, :, free_inds);
end

gof_free = (sum(alpha.^2, 1) / data_norm_sqr).';

safe_S = S_free;
safe_S(safe_S == 0) = 1;
scaled_alpha = alpha ./ safe_S;
scaled_alpha(S_free == 0) = 0;

source_est_3d = pagemtimes(V_free, reshape(scaled_alpha, 3, 1, n_free));
source_est = reshape(source_est_3d, 3, n_free);

src_norms = sqrt(sum(source_est.^2, 1));
safe_norms = src_norms;
safe_norms(safe_norms == 0) = 1;
source_est = source_est ./ safe_norms;

contributions = (gof_free.' .* source_est) / sqrt(3);

inds_x = 3 * free_inds - 2;
inds_y = 3 * free_inds - 1;
inds_z = 3 * free_inds;

z_vec(inds_x) = contributions(1, :).';
z_vec(inds_y) = contributions(2, :).';
z_vec(inds_z) = contributions(3, :).';

end
