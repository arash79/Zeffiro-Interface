

function [x,conv_val,n_iter] = pcg_iteration(A,b,tol_val,max_it,M,x)
%PCG_ITERATION  Preconditioned conjugate gradient for sparse FEM systems.
%
%   Zeffiro Interface (GPU-ToRRe-3D wave module).
%   Copyright © 2021- Sampsa Pursiainen & GPU-ToRRe-3D Development Team
%   See: https://github.com/sampsapursiainen/GPU-Torre-3D
%
%   Custom PCG used by NSE and wave solvers (distinct from zef_transfer_matrix
%   PCG in EEG lead fields). Accepts numeric matrix or function_handle A,
%   optional preconditioner M (function_handle, matrix, or [] for identity).
%   Relative residual sqrt(||r||^2/||b||^2) drives termination.
%
%   [x, conv_val, n_iter] = pcg_iteration(A, b, tol_val, max_it, M, x)
%
%   Input
%     A        - sparse matrix or function_handle @(x)
%     b        - [n × k] right-hand side (k right-hand sides allowed)
%     tol_val  - relative residual threshold
%     max_it   - iteration cap
%     M        - preconditioner matrix, function_handle, or [] (identity)
%     x        - initial guess, default zeros(n,1)
%
%   Output: x solution, conv_val last relative residual, n_iter count.
%
%   See also pcg_iteration_gpu, zef_transfer_matrix.


if nargin < 5
    M = [];
end

if nargin < 6
    x = zeros(size(b,1),1);
end

if isequal(class(A),'function_handle')
    r = - ( -b + A(x) );
else
    r = - ( -b + A*x );
end
if isequal(class(M),'function_handle')
    z = M(r);
elseif isempty(M)
    z = r;
else
    z = M\r;
end
p = z;
j = 1;

conv_val = sqrt(max(sum(r.^2)'./sum(b.^2)'));

%% PCG loop: minimize Ax-b with preconditioner M

while (conv_val > tol_val) & (j < max_it)
    if isequal(class(A),'function_handle')
        aux_vec = A(p);
    else
        aux_vec = A*p;
    end
    alpha = sum(z.*r)./sum(p.*aux_vec);
    x = x + alpha(ones(size(p,1),1),:).*p;
    rnew = r - alpha(ones(size(p,1),1),:).*aux_vec;
    if isequal(class(M),'function_handle')
        znew = M(rnew);
    elseif isempty(M)
        znew = rnew;
    else
        znew = M\rnew;
    end
    beta = sum(znew.*rnew)./sum(z.*r);
    p = znew + beta(ones(size(p,1),1),:).*p;
    r = rnew;
    z = znew;
    j = j + 1;
    conv_val = sqrt(max(sum(r.^2)'./sum(b.^2)'));
end

n_iter = j;

return
