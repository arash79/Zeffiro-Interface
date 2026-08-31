function self = precompute(self, L)
%precompute  Whiten L and store per-source SVD factorisations (U, S, V pages).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from run_frame_loop before the time loop. invert then uses
%   i_invert_cached. If noise_cov is empty, caches stay empty and invert
%   takes the per-call whitening path.
%
%   Chalf = sqrtm(noise_cov), whitening = Chalf \ I, L_w = whitening*L.
%   Each 3-column source block is SVD'd into U, S, V pages via pagesvd.
%   When reg_type is "Basic", singular values are Tikhonov-regularized.
%   Lead field must have a multiple of 3 columns (error otherwise).
%   gpuArray L is gathered before pagesvd.
%
%   Input  L  - n_sensors×(3 n_sources) processed lead field.
%   Output self with precomputed_L_w, precomputed_whitening,
%          precomputed_U_pages, precomputed_S_diag, precomputed_V_pages.

arguments
    self (1,1) inverse.DipoleScanInverter
    L (:,:) {mustBeA(L,["double","gpuArray"])}
end

self.precomputed_L_w = [];
self.precomputed_whitening = [];
self.precomputed_U_pages = [];
self.precomputed_S_diag = [];
self.precomputed_V_pages = [];
self.precomputed_cache_key = struct([]);

% Fingerprint L as the caller passed it, before the gather below, so that the
% key matches the one invert builds from the same argument.
cache_key = self.cacheKey(L);

if isempty(self.noise_cov)
    return;
end

if isa(L, 'gpuArray')
    L = gather(L);
end

n_ch = size(L, 1);
n_cols = size(L, 2);

if mod(n_cols, 3) ~= 0
    error("inverse:DipoleScanInverter:precompute:BadLeadFieldShape", ...
        "Lead field has %d columns; expected a multiple of 3 (3 columns per source).", n_cols);
end

n_sources = n_cols / 3;

Chalf = sqrtm(self.noise_cov);
if isa(Chalf, 'gpuArray')
    Chalf = gather(Chalf);
end

self.precomputed_whitening = Chalf \ eye(n_ch);
self.precomputed_L_w = self.precomputed_whitening * L;

reg_on = ~strcmp(self.reg_type, "None");
reg_param = self.reg_parameter;

% Batched thin SVD of every 3-column source block. pagesvd on the reshaped
% lead field is equivalent to svd(...,'econ') per page (same invert output)
% and avoids MATLAB loop overhead plus per-source n_ch×3 copies.
L_pages = reshape(self.precomputed_L_w, n_ch, 3, n_sources);
[U_pages, S_vec, V_pages] = pagesvd(L_pages, "econ", "vector");
S_diag = reshape(S_vec, 3, n_sources);
if reg_on
    S_diag = S_diag + reg_param;
end

self.precomputed_U_pages = U_pages;
self.precomputed_S_diag  = S_diag;
self.precomputed_V_pages = V_pages;
self.precomputed_cache_key = cache_key;

end
