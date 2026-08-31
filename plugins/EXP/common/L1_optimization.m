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
%   Scales A and y by 1/sigma (skipped when sigma==1). Each iter uses
%   d = |x|/gamma and the column-scaled Gram A diag(d) A' (no sparse D):
%   x = d .* A' (A diag(d) A' + reg sum(d) I)^{-1} b with
%   reg = sqrt(0.5*pi/m)*||A||_F. estimation_type==3 also applies
%   T_scale from the FOCUSS residual, reusing that Gram. Called from
%   exp_iteration and inverse.HALpRInverter.
%
%   See also LG_optimization, exp_iteration.

[m,~]=size(A);
if sigma ~= 1
    A = 1/sigma*A;
    b = 1/sigma*y;
else
    b = y;
end
reg = sqrt(0.5*pi/m)*norm(A,'fro');
I = eye(m);

for iter = 1 : maxiter
    % d = |x|/gamma is the FOCUSS diagonal. Form A diag(d) A' by column
    % scaling rather than an n×n sparse D (same arithmetic, far fewer
    % allocations). Ridge is reg·sum(d) I, reg = sqrt(π/(2m)) ‖A‖_F.
    % Type 3 also left-multiplies by T_scale = 1/sqrt(diag(R)) from the
    % current weighted resolution, reusing the same Gram.
    d = abs(x)./gamma;
    Ad = A.*d';
    ADA_T = Ad*A';
    if estimation_type == 3
        W = (ADA_T + I)\Ad;
        R = abs(sum(W.*Ad, 1));
        T_scale = 1./sqrt(R)';
        x = T_scale.*(d.*(A'*((ADA_T + (reg*sum(d))*I)\b)));
    else
        x = d.*(A'*((ADA_T + (reg*sum(d))*I)\b));
    end
end
end
