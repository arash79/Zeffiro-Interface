function x = LG_optimization(A,sigma,y,gamma,x,maxiter,estimation_type)
%LG_OPTIMIZATION  Group-L2 (3-component) inner loop for EXP.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   x = LG_optimization(A, sigma, y, gamma, x, maxiter, estimation_type)
%
%   Same linear solve as L1_optimization but D uses
%   repelem(sqrt(sum(reshape(x.^2,3,[]))),3) so each dipole's three
%   components share a weight. estimation_type==3 adds FOCUSS T_scale.
%   Else also tracks a dual gap (reltol 1e-4).
%
%   See also L1_optimization, exp_iteration.

dualObj = -Inf;
reltol = 1e-4;

[m,~]=size(A);
A = 1/sigma*A;
b = 1/sigma*y;
reg = sqrt(0.5*pi/m)*norm(A,'fro');

 for iter = 1 : maxiter
    if estimation_type == 3
        xL2 = repelem(sqrt(sum(reshape(x.^2,3,[]))),3)'+1e-12;
        P_sqrt = xL2./gamma;   %Fixed-point/FOCUSS
        L_aux = A.*P_sqrt';
        R = L_aux'/(L_aux*A'+eye(m));
        R = abs(sum(R.'.*L_aux,1));
        T_scale = 1./sqrt(R)';
        D = spdiags(xL2./gamma,0,size(A,2),size(A,2));
        ADA_T = A*(D*A');
        
        x = T_scale.*(D*(A'*((ADA_T + reg*trace(D)*eye(size(ADA_T)))\b)));
    else
        xL2 = repelem(sqrt(sum(reshape(x.^2,3,[]))),3)'+1e-10;
        D = spdiags(xL2./gamma,0,size(A,2),size(A,2));
        ADA_T = A*(D*A');
        %x = D*(A'*((ADA_T + reg*trace(D)*eye(size(ADA_T)))\b));
        x = D*(A'*((ADA_T + eye(size(ADA_T)))\b));
        
        %--------------------------------------
        %  DUAL GAP
        %--------------------------------------
        z = (A*x) - b;
        max_nu = sqrt(max(sum(reshape((A'*z).^2./gamma,3,[]),2)));
        if max_nu > 1
            nu = z/max_nu;
        else
            nu = z;
        end

        primaryObj = 0.5*(z'*z) + sum(gamma.*x);
        dualObj = max(-0.5*(nu'*nu)-nu'*b,dualObj);
        gap = primaryObj - dualObj;

        if gap/dualObj < reltol
            break;
        end

    end
end
end
