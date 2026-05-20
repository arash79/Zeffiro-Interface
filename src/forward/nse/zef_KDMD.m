function x = zef_KDMD(x,K,M,D,use_gpu)
% --- Zeffiro documentation header ---
% zef_KDMD — Zef KDMD.
%
% Purpose:
%   Zef KDMD.
%   Folder: Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.
%
% Inputs:
%   x
%   K
%   M
%   D
%   use_gpu
%
% Outputs:
%   x
%
% Calls (project):
%   zef_KDMD
%
% Side effects:
%   - GPU
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[x] = zef_KDMD(x, K, M, D, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if use_gpu
    x = gpuArray(x);
    K = gpuArray(K);
    M = gpuArray(M);
    D = gpuArray(D);
end

y = D*x;
y = M*y;
y = D*y;
x = K*x + y;

end
