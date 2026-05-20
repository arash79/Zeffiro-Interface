function x = L1_optimization(A,sigma,y,gamma,x,maxiter,estimation_type)
% --- Zeffiro documentation header ---
% L1_optimization — L1 optimization.
%
% Purpose:
%   L1 optimization.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   A
%   sigma
%   y
%   gamma
%   x
%   maxiter
%   estimation_type
%
% Outputs:
%   x
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[x] = L1_optimization(A, sigma, y, gamma, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

[m,~]=size(A);
A = 1/sigma*A;
b = 1/sigma*y;
reg = sqrt(0.5*pi/m)*norm(A,'fro');

for iter = 1 : maxiter
    if estimation_type == 3
        P_sqrt = abs(x)./gamma;   %Fixed-point/FOCUSS
        L_aux = A.*P_sqrt';
        R = L_aux'/(L_aux*A'+eye(m));
        R = abs(sum(R.'.*L_aux,1));
        T_scale = 1./sqrt(R)';
        D = spdiags(abs(x)./gamma,0,size(A,2),size(A,2));
        ADA_T = A*(D*A');

        x = T_scale.*(D*(A'*((ADA_T + reg*trace(D)*eye(size(ADA_T)))\b)));
    else
        D = spdiags(abs(x)./gamma,0,size(A,2),size(A,2));
        ADA_T = A*(D*A');
        x = D*(A'*((ADA_T + reg*trace(D)*eye(size(ADA_T)))\b));
    end
end
end
