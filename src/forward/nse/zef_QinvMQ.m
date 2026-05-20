function x = zef_QinvMQ(x,Q_1,Q_2,Q_3,M,tol,maxit,DM,use_gpu)
% --- Zeffiro documentation header ---
% zef_QinvMQ — Zef Qinv MQ.
%
% Purpose:
%   Zef Qinv MQ.
%   Folder: Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.
%
% Inputs:
%   x
%   Q_1
%   Q_2
%   Q_3
%   M
%   tol
%   maxit
%   DM
%   use_gpu
%
% Outputs:
%   x
%
% Calls (project):
%   zef_QinvMQ
%
% Side effects:
%   - GPU
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[x] = zef_QinvMQ(x, Q_1, Q_2, Q_3, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
