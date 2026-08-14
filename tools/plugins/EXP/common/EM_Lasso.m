function x = EM_Lasso(L,sigma,y,gamma,x0)
%EM_LASSO  EM updates for a Laplace-weighted Lasso (max 10 iters).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   x = EM_Lasso(L, sigma, y, gamma, x0)
%
%   A=L/sigma, b=y/sigma. invD = 0.5*|x|/gamma; x = (invD.*A')*(A invD A'+I)^{-1} b
%   until |log_new-log_old| < 1e-6 or 10 iters. Laplace log-prob uses
%   gamma.*abs(x). Used by EXP EM estimation_type.
%
%   See also L1_optimization, exp_em_iteration.

[m,~]=size(L);
A = 1/sigma*L;
b = 1/sigma*y;

converged = 0;
conv_thres = 1e-6;
maxiter=10;

iter=1;

log_prob_lap = @(x,gamma) -(m*log(sigma)+ 0.5 * (A*x-b)'*(A*x-b)+ 0.5* sum(gamma.*abs(x)))+sum(log(gamma));

%log_prob_lap = @(x,gamma) -(0.5 * (A*x-b)'*(A*x-b)+ 0.5* sum(gamma.*abs(x)));

x = x0; %initialization...

log_old = log_prob_lap(x,gamma);

iter_ind = 0;

while (converged==0)

    iter_ind = iter_ind + 1;

    invD = 0.5*abs(x)/gamma;
    ADA = A*(invD.*A');
    x = (invD.*A')*((ADA + eye(size(ADA)))\b);

    log_new = log_prob_lap(x,gamma);

    % % We have converged if the slope of the function falls below 'threshold',
    % % i.e., |f(t) - f(t-1)| / avg < threshold,
    % % where avg = (|f(t)| + |f(t-1)|)/2
    % % 'threshold' defaults to 1e-4.
    % % This stopping criterion is from Numerical Recipes in C p423

    delta_log = abs(log_new-log_old);
    avg_neg_log = (abs(log_new)+abs(log_old)+eps)/2;
    if (delta_log/avg_neg_log)<conv_thres
        converged=1;
    end
    %     if  (log_new-log_old)<-2*eps
    %           warning('convergenceTest:neglog_Decrease', 'objective decreased!');
    %     end

    log_old = log_new;

    if iter == maxiter
        break;
    end
    iter=iter+1;

end
end
