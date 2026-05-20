function self = precompute(self, L)
%PRECOMPUTE Cache frame-invariant factorisations for the Dipole Scan inverter.
%
% The dispatcher (utilities.cluster.dispatch_inverse via
% utilities.inverse.run_frame_loop) calls this once before the per-frame
% loop. The cached arrays let invert() process each frame with a single
% pagemtimes/matrix-multiply pair instead of a per-source SVD inside the
% per-frame loop.
%
% The cache holds the Mahalanobis whitening matrix (Chalf \ I), the
% whitened lead field, and per-source thin SVDs of the (optionally
% regularised) 3-column lead-field blocks. invert() uses the cache when it
% is populated and falls back to the legacy per-call SVD path otherwise, so
% callers that bypass run_frame_loop keep working unchanged.
%
% NOTE: Changing reg_type, reg_parameter, or noise_cov after this method
% has been called invalidates the cache. Re-run precompute(L) (or call
% invert directly with no precompute) in that case.

arguments
    self (1,1) inverse.DipoleScanInverter
    L (:,:) {mustBeA(L,["double","gpuArray"])}
end

self.precomputed_L_w = [];
self.precomputed_whitening = [];
self.precomputed_U_pages = [];
self.precomputed_S_diag = [];
self.precomputed_V_pages = [];

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

U_pages = zeros(n_ch, 3, n_sources);
S_diag  = zeros(3, n_sources);
V_pages = zeros(3, 3, n_sources);

for i = 1:n_sources
    ind3 = 3*i - [2, 1, 0];
    LF = self.precomputed_L_w(:, ind3);
    [U, S, V] = svd(LF, 'econ');

    s = diag(S);
    if reg_on
        s = s + reg_param;
    end

    U_pages(:, :, i) = U;
    S_diag(:, i)     = s;
    V_pages(:, :, i) = V;
end

self.precomputed_U_pages = U_pages;
self.precomputed_S_diag  = S_diag;
self.precomputed_V_pages = V_pages;

end
