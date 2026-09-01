function [z_vec, self] = invert(self, f, L, procFile, source_direction_mode, source_positions, opts)
%invert  Source-wise beamforming: loop fixed then free-orientation locations.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from utilities.inverse.run_frame_loop. Inverse tools → Beamformer
%   uses zef_beamformer, not this method.
%
%   If precompute stored the linear operator, z = B*f. Otherwise this file
%   regularizes error_cov, forms L_modified = C\L, and scans procFile.s_ind_4
%   (fixed) then free sources. Calling invert without error_cov leaves
%   L_modified undefined. Weights depend on method_type:
%     "Linearly constrained minimum variance (LCMV) beamformer"
%     "Unit noise gain (UNG) beamformer"
%     "Unit-gain constrained beamformer"
%   plus leadfield_reg_type ("Basic"|"Pseudoinverse") and
%   leadfield_normalization.
%
%   Inputs
%     f     - n_sensors×1 frame.
%     L     - n_sensors×n_dof processed lead field (3 columns per source
%             in Cartesian layout).
%     procFile.s_ind_0, .s_ind_4 - interpolated sources and constrained
%             subset (from zef_processLeadfields).
%     source_direction_mode, source_positions - unused here.
%     opts.use_gpu / normalize_data - GPU gather at the end; normalize unused.
%
%   Outputs
%     z_vec - n_dof×1 beamformer map for this frame.
%     self  - computing_parameters set false.

    arguments

        self (1,1) inverse.BeamformerInverter

        f (:,1) {mustBeA(f,["double","gpuArray"])}

        L (:,:) {mustBeA(L,["double","gpuArray"])}

        procFile (1,1) struct

        source_direction_mode

        source_positions

        opts.use_gpu (1,1) logical = false

        opts.normalize_data (1,1) double = 1

    end
    self.computing_parameters = false;

    % B is only valid for the lead field, orientation split and settings it
    % was built from. Drop it on any mismatch: B*f ignores the L passed in, so
    % a stale operator would otherwise be applied to a different model without
    % any warning.
    if ~isempty(self.precomputed_inverse_operator) ...
            && ~isequaln(self.precomputed_cache_key, self.cacheKey(L, procFile))
        self.precomputed_inverse_operator = [];
        self.precomputed_cache_key = struct([]);
    end

    % Fast path: if precompute stored B, each frame is one matrix–vector
    % product. Skip the nested waitbar — run_frame_loop already reports
    % frame progress, and B*f is milliseconds.
    has_cache = ~isempty(self.precomputed_inverse_operator);
    if has_cache
        f_use = f;
        if isa(f_use, "gpuArray")
            f_use = gather(f_use);
        end
        z_vec = self.precomputed_inverse_operator * f_use;
        return;
    end

    % Initialize waitbar with a cleanup object that automatically closes the
    % waitbar, if there is an interruption with Ctrl + C or when this function
    % exits. Only used by the legacy per-source path below.
    if self.number_of_frames <= 1
        h = zef_waitbar(0,'Beamforming reconstruction.');
        cleanup_fn = @zef_close_waitbar;
        cleanup_obj = onCleanup(@() cleanup_fn(h));
    end

    % Get needed parameters from self and others.
    lambda_cov = self.cov_reg_parameter;
    lambda_LF = self.leadfield_reg_parameter;
    date_str = NaN;
    LF_normalization = 1;

    % invert assumes initialize already filled error_cov (run_frame_loop).
    % C ← C + λ_cov tr(C)/m I; L_modified = C\L  (Mahalanobis / whitened L).
    if isempty(self.error_cov)
        error("BeamformerInverter:MissingErrorCov", ...
            "invert requires error_cov. Call initialize(L, f_data) first or set error_cov.");
    end
    C = self.error_cov;
    C = C + lambda_cov*trace(C)*eye(size(C))/size(f,1);
    L_modified = C\L;

    fixed_orientation_source_inds = procFile.s_ind_4;
    free_orientation_source_inds=setdiff(1:length(procFile.s_ind_0), procFile.s_ind_4);
    free_orientation_source_num = length(free_orientation_source_inds);
    waitbar_update_freq = floor(free_orientation_source_num/10);
    
    %Gather the lead field to make the script faster
    if opts.use_gpu
        L = gather(L);
        L_modified = gather(L_modified);
    end

    z_vec = zeros(size(L,2),1);
    
    % Then start inverting.
    % Per source: invLF ≈ (L' C^{-1} L + λ I)^{-1}; z = Weights * invLF * L_mod' f.

    % Fixed orientation (procFile.s_ind_4): one lead-field column per source
    % (the first of the 3-column Cartesian block). UNG and unit-gain constrained
    % share the scalar weight (LF'*LF_mod)/||LF_mod||; LCMV uses Weights = 1.
    % z(3-block) = Weights * inv(LF'*LF_mod + λ) * (LF_mod .* scale)' * f
    for i = 1:length(fixed_orientation_source_inds)
        ind3D = 3*fixed_orientation_source_inds(i) - [2,1,0];
        LF = L(:,3*fixed_orientation_source_inds(i));
        LF_modified = L_modified(:,3*fixed_orientation_source_inds(i));

        %Lead field normalization
        switch self.leadfield_normalization
            case "Matrix norm"
                LF_normalization = norm(LF);
            case "Column norm"
                LF_normalization = sqrt(sum(LF.^2,1));
            case "Row norm"
                LF_normalization = sqrt(sum(LF.^2,2));
        end
        %Lead field regularization 
        switch self.leadfield_reg_type
            case "Basic"
                invLF = inv(LF'*LF_modified+lambda_LF);
            case "Pseudoinverse"
                invLF = 1/(LF'*LF_modified);
        end

        switch self.method_type
            case "Linearly constrained minimum variance (LCMV) beamformer"
                Weights = 1;
            otherwise
                Weights = (LF'*LF_modified)/sqrt(sum(LF_modified.^2));
        end

        z_vec(ind3D) = Weights*invLF*(LF_modified.*LF_normalization)'*f;

    end

    % Free orientation: 3-column blocks. Unit-gain constrained first collapses
    % the block onto the dominant eigenvector of LF'*LF (Rayleigh–Ritz), then
    % uses the same scalar weight as the fixed-orientation UNG branch and
    % writes z back along that orientation / sqrt(3). Free UNG uses
    % sqrtm(LF_mod'*LF_mod) \ (LF'*LF_mod) (matrix weights).
    for i = 1:length(free_orientation_source_inds)
        %------- Waitbar computations -------
        if self.number_of_frames <=1
            tic;
            time_val = toc;
            date_str = display_waitbar(h,i,free_orientation_source_num,waitbar_update_freq,date_str,time_val);
        end

        ind3D = 3*free_orientation_source_inds(i) - [2,1,0];
        LF = L(:,ind3D);
        LF_modified = L_modified(:,ind3D);
        if strcmp(self.method_type,"Unit-gain constrained beamformer")
            %Optimal orientation is the one producing the strongest signal
            %Computed using Rayleigh-Ritz formula
            [optimal_orientation,~] = eigs(LF'*LF,1,'largestabs');
            optimal_orientation = optimal_orientation/sqrt(sum(optimal_orientation.^2));
            LF = LF*optimal_orientation;
            LF_modified = LF_modified*optimal_orientation;
        end

        %Lead field normalization
        switch self.leadfield_normalization
            case "Matrix norm"
                LF_normalization = norm(LF);
            case "Column norm"
                LF_normalization = sqrt(sum(LF.^2,1));
            case "Row norm"
                LF_normalization = sqrt(sum(LF.^2,2));
        end
        %Lead field regularization 
        switch self.leadfield_reg_type
            case "Basic"
                invLF = inv(LF'*LF_modified+lambda_LF*eye(size(LF,2)));
            case "Pseudoinverse"
                invLF = pinv(LF'*LF_modified);
        end

        switch self.method_type
            case "Linearly constrained minimum variance (LCMV) beamformer"
                Weights = 1;
            case "Unit noise gain (UNG) beamformer"
               Weights = sqrtm(LF_modified'*LF_modified)\(LF'*LF_modified);
            case "Unit-gain constrained beamformer"
                Weights = (LF'*LF_modified)/sqrt(sum(LF_modified.^2));
        end

        z_vec(ind3D) = Weights*invLF*(LF_modified.*LF_normalization)'*f;
        if strcmp(self.method_type,"Unit-gain constrained beamformer")
            %sqrt(s^2+s^2+s^2) = sqrt(3)*|s|
            z_vec(ind3D) = z_vec(ind3D).*optimal_orientation/sqrt(3);
        end
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
