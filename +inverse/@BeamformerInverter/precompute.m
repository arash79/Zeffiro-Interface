function self = precompute(self, L, procFile)
%precompute  Cache the linear beamformer operator B so invert is z = B*f.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from run_frame_loop before the time loop. Regularizes error_cov
%   exactly as invert (C ← C + λ_cov tr(C)/n I), forms L_mod = C\L, then
%   assembles the per-source weights into B. invert applies B*f. If
%   error_cov is empty, the cache stays empty and invert takes the
%   per-call loop. gpuArray L is gathered before the operator is built.
%
%   Inputs
%     L        - n_sensors×(3 n_sources) processed lead field (interleaved
%                Cartesian triplets after zef_process_inversion reorder).
%     procFile - optional; .s_ind_0 / .s_ind_4 distinguish free vs fixed
%                orientation. Omitted or empty s_ind_0 → all sources free.
%
%   Output self.precomputed_inverse_operator  n_dof×n_sensors, or [].

arguments
    self (1,1) inverse.BeamformerInverter
    L (:,:) {mustBeA(L,["double","gpuArray"])}
    procFile struct = struct("s_ind_0", [], "s_ind_4", [])
end

self.precomputed_inverse_operator = [];
self.precomputed_cache_key = struct([]);

% Fingerprint the caller's procFile before the defaults below are filled in,
% so that the key matches the one invert builds from the same argument.
cache_key = self.cacheKey(L, procFile);

if isempty(self.error_cov)
    return;
end

if isa(L, "gpuArray")
    L = gather(L);
end

n_ch = size(L, 1);
n_cols = size(L, 2);
if mod(n_cols, 3) ~= 0
    error("inverse:BeamformerInverter:precompute:BadLeadFieldShape", ...
        "Lead field has %d columns; expected a multiple of 3 (3 columns per source).", n_cols);
end

if isfield(procFile, "s_ind_0") && ~isempty(procFile.s_ind_0)
    n_src = length(procFile.s_ind_0);
else
    n_src = n_cols / 3;
    procFile.s_ind_0 = (1:n_src)';
end
if ~isfield(procFile, "s_ind_4") || isempty(procFile.s_ind_4)
    procFile.s_ind_4 = zeros(0, 1);
end

% Same ridge as invert: C ← C + λ_cov tr(C)/n_sensors I, then L_mod = C\L.
% Neither quantity depends on the measurement frame, so they are valid for
% every subsequent invert call until error_cov / L / method settings change.
C = self.error_cov;
if isa(C, "gpuArray")
    C = gather(C);
end
lambda_cov = self.cov_reg_parameter;
C = C + lambda_cov * trace(C) * eye(size(C)) / n_ch;
L_mod = C \ L;

self.precomputed_inverse_operator = i_build_operator( ...
    L, L_mod, procFile, n_src, ...
    self.method_type, self.leadfield_reg_type, ...
    self.leadfield_reg_parameter, self.leadfield_normalization);
self.precomputed_cache_key = cache_key;

end

function B = i_build_operator(L, L_mod, procFile, n_src, method_type, reg_type, lambda_LF, lf_norm)
n_ch = size(L, 1);
B = zeros(size(L, 2), n_ch);
fixed_inds = procFile.s_ind_4(:);
free_inds = setdiff((1:n_src)', fixed_inds);

if ~isempty(fixed_inds)
    B = i_fill_fixed(B, L, L_mod, fixed_inds, method_type, reg_type, lambda_LF, lf_norm);
end
if ~isempty(free_inds)
    B = i_fill_free(B, L, L_mod, free_inds, method_type, reg_type, lambda_LF, lf_norm);
end
end

function B = i_fill_fixed(B, L, L_mod, idx, method_type, reg_type, lambda_LF, lf_norm)
% Fixed-orientation sources use the Z column (3*idx), then write the same
% scalar beamformer row into all three Cartesian slots — matching invert.
cols = 3 * idx;
LF = L(:, cols);
LFm = L_mod(:, cols);
g = sum(LF .* LFm, 1);
switch lf_norm
    case "Matrix norm"
        LFm_s = LFm .* sqrt(sum(LF.^2, 1));
    case "Column norm"
        LFm_s = LFm .* sqrt(sum(LF.^2, 1));
    case "Row norm"
        LFm_s = LFm .* abs(LF);
    otherwise
        LFm_s = LFm;
end
switch reg_type
    case "Pseudoinverse"
        invLF = 1 ./ g;
    otherwise
        invLF = 1 ./ (g + lambda_LF);
end
if method_type == "Linearly constrained minimum variance (LCMV) beamformer"
    W = ones(size(g));
else
    W = g ./ sqrt(sum(LFm.^2, 1));
end
Brows = (LFm_s .* (W .* invLF)).';
B(3*idx-2, :) = Brows;
B(3*idx-1, :) = Brows;
B(3*idx, :)   = Brows;
end

function B = i_fill_free(B, L, L_mod, idx, method_type, reg_type, lambda_LF, lf_norm)
n_ch = size(L, 1);
n_all = size(L, 2) / 3;
n_free = numel(idx);
L_p = reshape(L, n_ch, 3, n_all);
Lm_p = reshape(L_mod, n_ch, 3, n_all);
if n_free ~= n_all
    L_p = L_p(:, :, idx);
    Lm_p = Lm_p(:, :, idx);
end

if method_type == "Unit-gain constrained beamformer"
    % Dominant eigenvector of LF'*LF (pageeig ≡ eigs(...,1,'largestabs')
    % up to sign). Reconstruction is even in the orientation, so the sign
    % does not change z.
    Gll = pagemtimes(L_p, "transpose", L_p, "none");
    [V, D] = pageeig(Gll);
    evals = zeros(3, n_free);
    evals(1, :) = D(1, 1, :);
    evals(2, :) = D(2, 2, :);
    evals(3, :) = D(3, 3, :);
    [~, k] = max(abs(evals), [], 1);
    V2 = reshape(V, 3, 3*n_free);
    ori = real(V2(:, k + 3*(0:n_free-1)));
    ori = ori ./ sqrt(sum(ori.^2, 1));
    ori_p = reshape(ori, 3, 1, n_free);
    LF_s = pagemtimes(L_p, ori_p);
    LFm_s = pagemtimes(Lm_p, ori_p);
    Lms = i_scale_1col(LF_s, LFm_s, lf_norm);
    g = reshape(pagemtimes(LF_s, "transpose", LFm_s, "none"), 1, n_free);
    switch reg_type
        case "Pseudoinverse"
            invLF = zeros(size(g));
            for i = 1:n_free
                invLF(i) = pinv(g(i));
            end
        otherwise
            invLF = 1 ./ (g + lambda_LF);
    end
    nrm = sqrt(reshape(sum(LFm_s.^2, 1), 1, n_free));
    W = g ./ nrm;
    row = reshape(Lms, n_ch, n_free) .* (W .* invLF / sqrt(3));
    B(3*idx-2, :) = (ori(1, :) .* row).';
    B(3*idx-1, :) = (ori(2, :) .* row).';
    B(3*idx, :)   = (ori(3, :) .* row).';
    return;
end

Lms = i_scale_3col(L_p, Lm_p, lf_norm);
G = pagemtimes(L_p, "transpose", Lm_p, "none");
switch reg_type
    case "Pseudoinverse"
        invLF = zeros(3, 3, n_free);
        for i = 1:n_free
            invLF(:, :, i) = pinv(G(:, :, i));
        end
    otherwise
        invLF = pageinv(G + lambda_LF * eye(3));
end
if method_type == "Unit noise gain (UNG) beamformer"
    Gm = pagemtimes(Lm_p, "transpose", Lm_p, "none");
    Weights = zeros(3, 3, n_free);
    for i = 1:n_free
        Weights(:, :, i) = sqrtm(Gm(:, :, i)) \ G(:, :, i);
    end
    W = pagemtimes(Weights, invLF);
else
    W = invLF;
end
Bpages = pagemtimes(W, pagetranspose(Lms));
B(3*idx-2, :) = reshape(Bpages(1, :, :), n_ch, n_free).';
B(3*idx-1, :) = reshape(Bpages(2, :, :), n_ch, n_free).';
B(3*idx, :)   = reshape(Bpages(3, :, :), n_ch, n_free).';
end

function Lms = i_scale_3col(L_p, Lm_p, lf_norm)
switch lf_norm
    case "Matrix norm"
        % MATLAB norm(LF) on a 3-column block is the spectral 2-norm.
        s = pagesvd(L_p, "econ", "vector");
        Lms = Lm_p .* s(1, 1, :);
    case "Column norm"
        Lms = Lm_p .* sqrt(sum(L_p.^2, 1));
    case "Row norm"
        Lms = Lm_p .* sqrt(sum(L_p.^2, 2));
    otherwise
        Lms = Lm_p;
end
end

function Lms = i_scale_1col(LF_s, LFm_s, lf_norm)
switch lf_norm
    case "Matrix norm"
        Lms = LFm_s .* sqrt(sum(LF_s.^2, 1));
    case "Column norm"
        Lms = LFm_s .* sqrt(sum(LF_s.^2, 1));
    case "Row norm"
        Lms = LFm_s .* abs(LF_s);
    otherwise
        Lms = LFm_s;
end
end
