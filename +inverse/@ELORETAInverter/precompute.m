function self = precompute(self, L, procFile)
%PRECOMPUTE Build cached eLORETA inverse operator.

arguments
    self (1,1) inverse.ELORETAInverter
    L (:,:) {mustBeA(L,["double","gpuArray"])}
    procFile (1,1) struct = struct()
end

n_sensors = size(L,1);
n_cols = size(L,2);
alpha = self.regularization_parameter;

if self.apply_average_reference
    H = eye(n_sensors, "like", L) - ones(n_sensors, "like", L)/n_sensors;
else
    H = eye(n_sensors, "like", L);
end

W_inv = eye(n_cols, "like", L);
n_iterations = 0;
residual = Inf;

has_triplets = mod(n_cols, 3) == 0;
if has_triplets
    n_sources = n_cols/3;
else
    n_sources = n_cols;
end

fixed_source_inds = [];
if isstruct(procFile) && isfield(procFile, "s_ind_4")
    fixed_source_inds = procFile.s_ind_4(:);
end
free_source_inds = setdiff((1:n_sources)', fixed_source_inds);

for k = 1:self.n_max_iterations
    n_iterations = k;

    M = L * W_inv * L' + alpha * H;
    Minv = i_stable_inverse(M);

    W_inv_new = zeros(n_cols, n_cols, "like", L);

    if has_triplets
        for i = free_source_inds'
            ind = 3*i - [2,1,0];
            A_i = L(:,ind)' * Minv * L(:,ind);
            A_i = (A_i + A_i')/2;
            [V_i, D_i] = eig(A_i);
            eig_vals = real(diag(D_i));
            eig_floor = eps(i_underlying_class(A_i)) * max(1, max(abs(eig_vals)));
            eig_vals = max(eig_vals, eig_floor);
            block_inv = V_i * diag(1./sqrt(eig_vals)) * V_i';
            W_inv_new(ind,ind) = (block_inv + block_inv')/2;
        end

        for i = fixed_source_inds'
            ind = 3*i - [2,1,0];
            scalar_val = real(L(:,ind(1))' * Minv * L(:,ind(1)));
            scalar_floor = eps(i_underlying_class(M)) * max(1, abs(scalar_val));
            scalar_val = max(scalar_val, scalar_floor);
            W_inv_new(ind,ind) = eye(3, "like", L) / sqrt(scalar_val);
        end
    else
        diag_terms = real(sum(L .* (Minv * L), 1))';
        diag_floor = eps(i_underlying_class(M)) * max(1, max(abs(diag_terms)));
        diag_terms = max(diag_terms, diag_floor);
        W_inv_new = diag(1./sqrt(diag_terms));
    end

    residual = norm(W_inv_new - W_inv, "fro") / max(norm(W_inv, "fro"), eps(i_underlying_class(W_inv)));
    W_inv = W_inv_new;

    if residual < self.convergence_tolerance
        break;
    end
end

M_final = L * W_inv * L' + alpha * H;
Minv_final = i_stable_inverse(M_final);

self.precomputed_inverse_operator = W_inv * (L' * Minv_final);
self.precomputed_W_inv_diag = diag(W_inv);
self.n_iterations_used = n_iterations;
if isa(residual, "gpuArray")
    self.final_residual = gather(residual);
else
    self.final_residual = residual;
end

end

function Minv = i_stable_inverse(M)
I = eye(size(M,1), "like", M);
try
    M_decomp = decomposition(M, "chol");
    Minv = M_decomp \ I;
catch
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
