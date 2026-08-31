function x = zef_QinvMQ(x,Q_1,Q_2,Q_3,M,tol,maxit,DM,use_gpu)
%ZEF_QINVMQ  Apply Q^{-1} M Q^{-1} to a 3-block vector (NSE pressure projection).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Computes Q_i x, solves M y_i = Q_i x with pcg_iteration(_gpu) using
%   diagonal preconditioner DM, then returns sum_i Q_i' y_i. Called from
%   zef_nse_iteration for the divergence-free projection.
%
%   x = zef_QinvMQ(x, Q_1, Q_2, Q_3, M, tol, maxit, DM, use_gpu)
%
%   Input: sparse Q_i, mass M, vector x (n_nodes), logical use_gpu.
%
%   See also pcg_iteration, zef_nse_iteration.

if use_gpu
    x = gpuArray(x);
    Q_1 = gpuArray(Q_1);
    Q_2 = gpuArray(Q_2);
    Q_3 = gpuArray(Q_3);
    M = gpuArray(M);
    DM = gpuArray(DM);
end

x_1 = Q_1*x;
x_2 = Q_2*x;
x_3 = Q_3*x;

% Solve M y_i = Q_i x (lumped/consistent mass) then assemble ∑ Q_i' y_i.

if use_gpu
    [x_1] = pcg_iteration_gpu(M,x_1,tol,maxit,DM,x_1);
else
    [x_1] = pcg_iteration(M,x_1,tol,maxit,DM,x_1);
end

if use_gpu
    [x_2] = pcg_iteration_gpu(M,x_2,tol,maxit,DM,x_2);
else
    [x_2] = pcg_iteration(M,x_2,tol,maxit,DM,x_2);
end

if use_gpu
    [x_3] = pcg_iteration_gpu(M,x_3,tol,maxit,DM,x_3);
else
    [x_3] = pcg_iteration(M,x_3,tol,maxit,DM,x_3);
end

x_1 = Q_1*x_1;
x_2 = Q_2*x_2;
x_3 = Q_3*x_3;

x = x_1 + x_2 + x_3;

end
