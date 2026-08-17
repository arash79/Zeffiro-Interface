function x = L1_optimization(A,sigma,y,gamma,x,maxiter,estimation_type)
%L1_OPTIMIZATION  Weighted L1 inner loop for EXP (FOCUSS if type==3).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   x = L1_optimization(A, sigma, y, gamma, x, maxiter, estimation_type)
%
%   Scales A and y by 1/sigma. D = diag(|x|/gamma). Each iter:
%   x = D A' (A D A' + reg trace(D) I)^{-1} b with
%   reg = sqrt(0.5*pi/m)*||A||_F. estimation_type==3 also applies
%   T_scale from the FOCUSS residual. Called from exp_iteration.
%
%   See also LG_optimization, EM_Lasso, exp_iteration.

[m,~]=size(A);
A = 1/sigma*A;
b = 1/sigma*y;
reg = sqrt(0.5*pi/m)*norm(A,'fro');

for iter = 1 : maxiter
    % D = diag(|x|/gamma) is the FOCUSS weight. The sensor-side Gram
    % A D A' is ridge-regularized with reg·trace(D) I,
    % reg = sqrt(π/(2m)) ‖A‖_F. Type 3 also left-multiplies by
    % T_scale = 1/sqrt(diag(R)) from the current weighted resolution.
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
