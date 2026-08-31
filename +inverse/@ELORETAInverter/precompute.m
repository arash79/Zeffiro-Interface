function self = precompute(self, L, procFile)
%precompute  Fixed-point eLORETA iteration; cache inverse operator T = W^{-1} L' M^{-1}.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Iterates W^{-1} from the eLORETA fixed-point rule with M = L W^{-1} L' + alpha H,
%   where H is average-reference (I - 11'/n) or identity. W^{-1} is block-diagonal
%   (3×3 per source) or diagonal, so it is stored as 3×3×n_sources pages (or a
%   vector) rather than a dense n_dof×n_dof matrix. Free-orientation updates use
%   batched pageeig; fixed-orientation sources (procFile.s_ind_4) use the same
%   scalar rule as before. Stores precomputed_inverse_operator and convergence
%   diagnostics in n_iterations_used / final_residual.
%
%   Inputs:  self, L, procFile (optional struct with s_ind_4 fixed sources).
%   Output:  self with precomputed_inverse_operator set.

arguments
    self (1,1) inverse.ELORETAInverter
    L (:,:) {mustBeA(L,["double","gpuArray"])}
    procFile (1,1) struct = struct()
end

n_sensors = size(L,1);
n_cols = size(L,2);
alpha = self.regularization_parameter;
underlying = i_underlying_class(L);

if self.apply_average_reference
    H = eye(n_sensors, "like", L) - ones(n_sensors, "like", L)/n_sensors;
else
    H = eye(n_sensors, "like", L);
end

has_triplets = mod(n_cols, 3) == 0;
if has_triplets
    n_sources = n_cols/3;
    L_p = reshape(L, n_sensors, 3, n_sources);
    W_pages = zeros(3, 3, n_sources, "like", L);
    W_pages(1,1,:) = 1;
    W_pages(2,2,:) = 1;
    W_pages(3,3,:) = 1;
else
    n_sources = n_cols;
    L_p = [];
    W_diag = ones(n_cols, 1, "like", L);
end

fixed_source_inds = [];
if isstruct(procFile) && isfield(procFile, "s_ind_4")
    fixed_source_inds = procFile.s_ind_4(:);
end
free_source_inds = setdiff((1:n_sources)', fixed_source_inds);

n_iterations = 0;
residual = Inf;

for k = 1:self.n_max_iterations
    n_iterations = k;

    % M = L W^{-1} L' + alpha H; invert stably (Cholesky or pinv).
    if has_triplets
        M = reshape(pagemtimes(L_p, W_pages), n_sensors, n_cols) * L' + alpha * H;
    else
        M = (L .* W_diag.') * L' + alpha * H;
    end
    Minv = i_stable_inverse(M, self.apply_average_reference);
    K = Minv * L;

    if has_triplets
        K_p = reshape(K, n_sensors, 3, n_sources);
        W_pages_new = zeros(3, 3, n_sources, "like", L);

        if ~isempty(free_source_inds)
            if numel(free_source_inds) == n_sources
                L_free = L_p;
                K_free = K_p;
            else
                L_free = L_p(:, :, free_source_inds);
                K_free = K_p(:, :, free_source_inds);
            end
            A = pagemtimes(L_free, "transpose", K_free, "none");
            W_pages_new(:, :, free_source_inds) = i_invsqrt_pages(A, underlying);
        end

        if ~isempty(fixed_source_inds)
            cols1 = 3*fixed_source_inds - 2;
            scalar_val = real(sum(L(:, cols1) .* K(:, cols1), 1));
            scalar_floor = eps(underlying) * max(1, abs(scalar_val));
            scalar_val = max(scalar_val, scalar_floor);
            scale = 1 ./ sqrt(scalar_val);
            I3 = eye(3, "like", L);
            W_pages_new(:, :, fixed_source_inds) = I3 .* reshape(scale, 1, 1, []);
        end

        residual = sqrt(sum(abs(W_pages_new(:) - W_pages(:)).^2)) ...
            / max(sqrt(sum(abs(W_pages(:)).^2)), eps(underlying));
        W_pages = W_pages_new;
    else
        diag_terms = real(sum(L .* K, 1))';
        diag_floor = eps(underlying) * max(1, max(abs(diag_terms)));
        diag_terms = max(diag_terms, diag_floor);
        W_diag_new = 1 ./ sqrt(diag_terms);
        residual = norm(W_diag_new - W_diag) / max(norm(W_diag), eps(underlying));
        W_diag = W_diag_new;
    end

    if residual < self.convergence_tolerance
        break;
    end
end

if has_triplets
    M_final = reshape(pagemtimes(L_p, W_pages), n_sensors, n_cols) * L' + alpha * H;
else
    M_final = (L .* W_diag.') * L' + alpha * H;
end
Minv_final = i_stable_inverse(M_final, self.apply_average_reference);
K_final = Minv_final * L;

if has_triplets
    K_p = reshape(K_final, n_sensors, 3, n_sources);
    T_pages = pagemtimes(W_pages, pagetranspose(K_p));
    self.precomputed_inverse_operator = reshape(permute(T_pages, [1 3 2]), n_cols, n_sensors);
    w_diag = zeros(3, n_sources, "like", L);
    w_diag(1,:) = W_pages(1,1,:);
    w_diag(2,:) = W_pages(2,2,:);
    w_diag(3,:) = W_pages(3,3,:);
    self.precomputed_W_inv_diag = w_diag(:);
else
    self.precomputed_inverse_operator = W_diag .* K_final';
    self.precomputed_W_inv_diag = W_diag;
end

self.n_iterations_used = n_iterations;
if isa(residual, "gpuArray")
    self.final_residual = gather(residual);
else
    self.final_residual = residual;
end
self.precomputed_cache_key = self.cacheKey(L, procFile);

end

function Minv = i_stable_inverse(M, average_reference)
M = 0.5 * (M + M');
I = eye(size(M,1), "like", M);
if average_reference
    % H = I - 11'/n is singular, and average-referenced L lives in the
    % same (n-1)-space, so M is rank-deficient by construction. pinv is
    % the Moore–Penrose inverse on that subspace, not a numerical rescue.
    Minv = pinv(M);
    return
end
try
    M_decomp = decomposition(M, "chol");
    Minv = M_decomp \ I;
catch
    warning("Zeffiro:ELORETA:CholeskyFallback", ...
        "eLORETA Cholesky of the sensor-space Gram failed; using pinv. Check rank(L) and alpha.");
    Minv = pinv(M);
end
end

function underlying = i_underlying_class(A)
if isa(A, "gpuArray")
    underlying = classUnderlying(A);
else
    underlying = class(A);
end
end

function blocks = i_invsqrt_pages(A, underlying)
%I_INVSQRT_PAGES  Symmetric inverse square root of 3×3 pages via pageeig.
ns = size(A, 3);
A = 0.5 * (A + pagetranspose(A));
[V, D] = pageeig(A);
evals = zeros(3, ns, "like", A);
evals(1,:) = D(1,1,:);
evals(2,:) = D(2,2,:);
evals(3,:) = D(3,3,:);
evals = real(evals);
eig_floor = eps(underlying) * max(1, max(abs(evals), [], 1));
evals = max(evals, eig_floor);
Dinv = zeros(3, 3, ns, "like", A);
Dinv(1,1,:) = 1 ./ sqrt(evals(1,:));
Dinv(2,2,:) = 1 ./ sqrt(evals(2,:));
Dinv(3,3,:) = 1 ./ sqrt(evals(3,:));
blocks = pagemtimes(pagemtimes(V, Dinv), pagetranspose(V));
blocks = 0.5 * (blocks + pagetranspose(blocks));
end
