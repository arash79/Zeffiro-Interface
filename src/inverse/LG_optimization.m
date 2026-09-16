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
%   Same linear solve as L1_optimization but the diagonal weight is the
%   per-dipole L2, repelem(sqrt(sum(reshape(x.^2,3,[]))),3), so each
%   dipole's three components share a weight. Forms A diag(d) A' by
%   scaling rather than an n×n sparse D. estimation_type==3 adds FOCUSS
%   T_scale and ridge reg·sum(d)·I, reusing that Gram. Else the ridge is
%   I (not the unused Frobenius ridge) and a dual gap (reltol 1e-4) is
%   tracked. Scaling by 1/sigma is skipped when sigma==1. Lives in
%   src/inverse so class solvers resolve it without genpath(plugins).
%
%   See also L1_optimization, exp_iteration, inverse.GroupLassoInverter.

dualObj = -Inf;
reltol = 1e-4;

[m,~]=size(A);
if sigma ~= 1
    A = 1/sigma*A;
    b = 1/sigma*y;
else
    b = y;
end
I = eye(m);

if estimation_type == 3
    reg = sqrt(0.5*pi/m)*norm(A,'fro');
    for iter = 1 : maxiter
        xL2 = repelem(sqrt(sum(reshape(x.^2,3,[]))),3)'+1e-12;

        d = xL2./gamma;

        % For the standardization factor R:
        % Ad*Ad' = A*diag(d.^2)*A'
        Ad = A.*d';
        AD2A_T = Ad*Ad';

        R = Ad'/(AD2A_T + I);
        R = abs(sum(R'.*Ad,1));
        T_scale = 1./sqrt(R)';

        % For the actual weighted inverse:
        % A*(d.*A') = A*diag(d)*A'
        ADA_T = A*(d.*A');

        x = T_scale.*(d.*(A'*((ADA_T + (reg*sum(d))*I)\b)));
    end
else
    for iter = 1 : maxiter
        xL2 = repelem(sqrt(sum(reshape(x.^2,3,[]))),3)'+1e-10;
        d = xL2./gamma;
        ADA_T = A*(d.*A');
        u = (ADA_T + I)\b;
        Atu = A'*u;
        x = d.*Atu;

        %--------------------------------------
        %  DUAL GAP
        %--------------------------------------
        % (ADA_T+I)u = b and ADA_T = A diag(d) A' imply A*x-b = -u.
        z = -u;
        max_nu = sqrt(max(sum(reshape(Atu.^2./gamma,3,[]),2)));
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
