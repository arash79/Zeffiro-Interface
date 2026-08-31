function [log_lh, mahalaD] = WeightedCondDensity(positions, mu, ~, Sigma, p, sharedCov, CovType)
%WEIGHTEDCONDDENSITY  Log component densities for the ClassGMM EM loop.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   LOG_LH(i,j) = log(alpha_j * p(x_i | theta_j)). The third argument is
%   unused (observation weights are applied in EstepWeight). COVTYPE 1 =
%   diagonal, 2 = full. Called from AdvGMModeling4Rec.
%
%   See also inverse.gmm.EstepWeight, inverse.gmm.AdvGMModeling4Rec.

log_prior = log(p);
    [n,d]=size(positions);
    k=size(mu,1);
    log_lh = zeros(n,k,'like',positions);
    if nargout > 1
      mahalaD = zeros(n,k,'like',positions);
    end
    logDetSigma = -Inf;
    for j = 1:k
        if sharedCov
            if j == 1
                if CovType == 2 % full covariance
                    [L,f] = chol(Sigma);
                    diagL = diag(L);
                    if (f ~= 0)|| any(abs(diagL) < eps(max(abs(diagL)))*size(L,1))
                        error(message('stats:gmdistribution:wdensity:IllCondCov'));
                    end
                    logDetSigma = 2*sum(log(diagL));
                else %diagonal
                    L = sqrt(Sigma);
                    if  any(L < eps( max(L))*d)
                          error(message('stats:gmdistribution:wdensity:IllCondCov'));
                    end
                    logDetSigma = sum( log(Sigma) );
                end
            end
        else %different covariance
            if CovType == 2 % full covariance
                % compute the log determinant of covariance
                [L,f] = chol(Sigma(:,:,j) );
                diagL = diag(L);
                if (f ~= 0) || any(abs(diagL) < eps(max(abs(diagL)))*size(L,1))
                     error(message('stats:gmdistribution:wdensity:IllCondCov'));
                end
                logDetSigma = 2*sum(log(diagL));
            else %diagonal covariance
                L = sqrt(Sigma(:,:,j)); % a vector
                if  any(L < eps(max(L))*d)
                     error(message('stats:gmdistribution:wdensity:IllCondCov'));
                end
                logDetSigma = sum(log(Sigma(:,:,j)) );
            end
        end
        
        if CovType == 2
             log_lh(:,j) = sum(((positions - mu(j,:))/L).^2, 2);
        else
             log_lh(:,j) = sum(((positions - mu(j,:))./L).^2, 2);
        end
        
        if nargout > 1
             mahalaD(:,j) = log_lh(:,j);
        end
        log_lh(:,j) = -0.5*(log_lh(:,j) + logDetSigma);
    end
% Add log prior and Gaussian normalization: log_lh(i,j) = log(alpha_j * p(x_i|theta_j))
log_lh = log_lh + log_prior - d*log(2*pi)/2;
