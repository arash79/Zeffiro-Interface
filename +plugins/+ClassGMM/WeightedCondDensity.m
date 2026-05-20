function [log_lh, mahalaD] = WeightedCondDensity(positions, mu, weight, Sigma, p, sharedCov, CovType)
%WEIGHTEDCONDDENSITY Log component-conditional density for weighted GMM.
%
%   LOG_LH = WEIGHTEDCONDDENSITY(POSITIONS, MU, WEIGHT, SIGMA, P, SHAREDCOV, COVTYPE)
%   computes the log of the component-conditional density weighted by mixing
%   proportions. LOG_LH is N-by-K where LOG_LH(i,j) = log(alpha_j * p(x_i | theta_j)).
%
%   Inputs:
%     POSITIONS - N-by-D matrix of observations
%     MU        - K-by-D matrix of component means
%     WEIGHT    - Observation weights (reserved for future use)
%     SIGMA     - Covariance (format depends on SHAREDCOV and COVTYPE)
%     P         - 1-by-K mixing proportions
%     SHAREDCOV - true if all components share one covariance
%     COVTYPE   - 1 = diagonal, 2 = full covariance
%
%   Outputs:
%     LOG_LH   - N-by-K matrix of log(alpha_j * p(x_i|theta_j))
%     MAHALAD  - (Optional) N-by-K Mahalanobis distances
%
%   Copyright 2015 The MathWorks, Inc.

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
             %log_lh(:,j) = sum(weight.*((positions - mu(j,:))/L).^2, 2); 
             log_lh(:,j) = sum(((positions - mu(j,:))/L).^2, 2); 
        else %diagonal covariance
             %log_lh(:,j) = sum(((positions - mu(j,:))./L).^2, 2); 
             log_lh(:,j) = sum(((positions - mu(j,:))./L).^2, 2); 
        end
        
        if nargout > 1
             mahalaD(:,j) = log_lh(:,j);
        end
        log_lh(:,j) = -0.5*(log_lh(:,j) + logDetSigma);
    end
% Add log prior and Gaussian normalization: log_lh(i,j) = log(alpha_j * p(x_i|theta_j))
log_lh = log_lh + log_prior - d*log(2*pi)/2;

   
