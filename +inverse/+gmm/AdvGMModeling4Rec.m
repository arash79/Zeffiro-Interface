function [S,NlogL,optimInfo]...
    =AdvGMModeling4Rec(X,weight,k,start,reps, CovType,SharedCov, RegV, options,probtol)
%ADVGMMODELING4REC  Weighted EM loop for ClassGMM (called from FitAdvGMM).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [S, NlogL, optimInfo] = AdvGMModeling4Rec(X, weight, k, start, reps, ...
%       CovType, SharedCov, RegV, options, probtol)
%
%   Inputs
%     X        - N-by-D sample matrix (reconstruction coordinates, optionally
%                with orientation components).
%     weight   - N-by-1 observation weights (reconstruction amplitude).
%     k        - number of components.
%     start    - 'plus', 'randSample', a parameter struct, or an N-vector of
%                component indices (partition). Struct / partition force reps=1.
%     reps     - independent EM restarts; the highest-likelihood fit is kept.
%     CovType  - 1 diagonal, 2 full (numeric codes from FitAdvGMM).
%     SharedCov, RegV - shared covariance flag; diagonal ridge added to Sigma.
%     options  - statset('gmdistribution') options (MaxIter, Display, TolFun).
%     probtol  - posterior floor passed to estep (FitAdvGMM default 1e-8).
%
%   Outputs
%     S        - struct with PComponents, mu, Sigma.
%     NlogL    - negative log-likelihood of the best replicate.
%     optimInfo - .Converged, .Iters.
%
%   Each M-step calls EstepWeight to re-exponentiate observation weights.
%   Requires Statistics Toolbox message IDs used by gmdistribution.
%
%   See also inverse.gmm.FitAdvGMM.

[n,d]=size(X);

% Validate and parse the initialization method
if isstruct(start)
    initPara=checkInitParam(start,k,d,CovType, SharedCov);
    start = 'parameter';
    if reps ~= 1
        error(message('stats:gmdistribution:ConflictReps'));
    end
elseif isvector(start) && isnumeric(start)
    if length(start) ~= n
        error(message('stats:gmdistribution:MisshapedInitIdx'));
    end
    if ~all(ismember(start, 1:k) )  || ~all(ismember(1:k,start))
        error(message('stats:gmdistribution:WrongInitIdx'));
    end
    initIdx = start;
    start='partition';
    if reps ~= 1
        error(message('stats:gmdistribution:ConflictReps'));
    end
elseif ischar(start) 
    if strncmpi(start,'randsample',length(start))
        start='randsample';
    elseif strncmpi(start,'plus',length(start))
        start='plus';
    else
        error(message('stats:gmdistribution:BadStart'));
    end
    
else
    error(message('stats:gmdistribution:BadStart'));
 end

% Initialize best solution tracking across replicates
max_ll =- inf;
S = [];
optimInfo = [];
illCondCnt = 0;

% Run EM algorithm for each replicate; retain the solution with highest likelihood
for t = 1:reps
    switch start
        case 'randsample'
            initPara = randInitParam(X,k, CovType, SharedCov,RegV);
        case 'plus'   % {'fullplus'}
             initPara = plusInitParam(X,weight,k, CovType, SharedCov,RegV);
        case 'partition'
            initPara = partInitParam(X,k,CovType, SharedCov,RegV,initIdx);
    end
    if (  options.Display >1) && reps > 1 %final or iter
        fprintf('\n%s\n',getString(message('stats:gmdistribution:gmcluster_Repetition', t)));
    end

    % run Gaussian mixture clustering once.
    % At this point, the initial parameter should be given
    try
        [S0,ll0,  optimInfo0] = gmcluster_learn...
            (X, weight, k, initPara,  CovType, SharedCov, RegV,options,probtol);
        if ~optimInfo0.Converged
                  
           if reps==1
                warning(message('stats:gmdistribution:FailedToConverge', options.MaxIter,k));
           else
                warning(message('stats:gmdistribution:FailedToConvergeReps', options.MaxIter, t,k));
           end
        end

        if options.Display > 1 % 'final' or 'iter'
              fprintf('%d iterations, log-likelihood = %g\n',optimInfo0.Iters,ll0);
        end

        if  ll0 > max_ll % keep the best one
            S = S0;
            max_ll = ll0;
            optimInfo = optimInfo0;
        end
    catch ME
        if reps == 1 || (~isequal(ME.identifier,'stats:gmdistribution:IllCondCov') && ...
                         ~isequal(ME.identifier,'stats:gmdistribution:IllCondCovIter'))
            rethrow(ME);
        else
            illCondCnt = illCondCnt + 1;
            warning(message('stats:gmdistribution:IllCondCov', t, k, ME.message( strfind( ME.message, sprintf( '\n' ) ) + 1:end )));

            if illCondCnt == reps
                m = message('stats:gmdistribution:IllCondCovAllReps');
                throwAsCaller(MException(m.Identifier,'%s',getString(m)));
            end
        end
    end

end %  reps

NlogL = -max_ll;

end

function [S,ll, optimInfo] = ...
    gmcluster_learn(X, weight, k, initPara, CovType, SharedCov,regVal,options,postprob_th)

import inverse.gmm.*

[n,d] = size(X);
% Threshold for sparse-indexing optimization: use when < 40% of points have
% non-zero posterior for a component (avoids full matrix operations)
th = floor(n*0.4);

% Allocate memory for parameter structure
S = initPara;
ll_old = -inf;
%postprob_th is 1e-8 by default;
optimInfo.Converged = false;
optimInfo.Iters=0;

dispfmt = '%6d\t%12g\n';

if options.Display > 2 % 'iter'
   fprintf('  iter\t    log-likelihood\n');
end
if CovType == 2
    regVal = regVal * eye(d,'like',X);
end
% For full covariance or high dimensions, threshold small posteriors to
% improve numerical stability and computational efficiency
setSmallProbtoZero = false;
if CovType == 2 || d > 8
    setSmallProbtoZero = true;
end

weight_org = weight;

for iter = 1:options.MaxIter
    % --- E-step: Compute posterior probabilities P(component j | x_i) ---
    try
        log_lh=WeightedCondDensity(X,S.mu,weight, S.Sigma, S.PComponents, SharedCov, CovType);
        if  setSmallProbtoZero
           [ll,post] = estep(log_lh,postprob_th);
        else
           [ll,post] = estep(log_lh);
        end
    catch ME
        if ~isequal(ME.identifier,'stats:gmdistribution:wdensity:IllCondCov')
            rethrow(ME);
        else
            m = message('stats:gmdistribution:IllCondCovIter',iter);
            throwAsCaller(MException(m.Identifier,'%s',getString(m)));
        end
    end
    if options.Display > 2 %'iter'
        fprintf(dispfmt, iter, ll);
    end

    % --- Convergence check: terminate if log-likelihood change is below tolerance ---
    llDiff = ll-ll_old;
    if llDiff >= 0 && llDiff < options.TolFun *abs(ll)
        optimInfo.Converged=true;
        break;
    end
    ll_old = ll;

    % Update observation weights based on E-step posteriors (weighted GMM
    % extension for source reconstruction)
    weight = EstepWeight(log_lh,post,weight_org);

    % Apply weights to posteriors and accumulate component responsibilities
    post = weight.*post;
    S.PComponents = sum(post,1);

    % --- M-step: Update component means (mu), covariances (Sigma), and mixing proportions ---
   
    if SharedCov %common covariance
        if CovType == 2  %full covariance
            S.Sigma = zeros(d,d,'like',X);
            for j = 1:k
                if S.PComponents(j) == 0 
                    %When the small posterior probablities are set to zero,
                    % it's possilble to get a cluster with zero prior.
                    continue;
                end
                S.mu(j,:) = post(:,j)' * X / S.PComponents(j);
                Xcentered = X - S.mu(j,:);
                Xcentered = bsxfun(@times,sqrt(post(:,j)),Xcentered);
                S.Sigma = S.Sigma + Xcentered'*Xcentered;
            end
         else %diagonal
            S.Sigma = zeros(1,d,'like',X);
            for j = 1:k
                if S.PComponents(j) == 0 
                    %When the small posterior probablities are set to zero,
                    % it's possilble to get a cluster with zero prior.
                    continue;
                end
                S.mu(j,:) = post(:,j)' * X / S.PComponents(j);
                Xcentered =  X - S.mu(j,:);
                S.Sigma = S.Sigma + post(:,j)' *(Xcentered.^2);
            end      
        end
        S.Sigma = S.Sigma/sum(S.PComponents)+regVal;
    else %different covariance
        for j = 1:k
            if S.PComponents(j) == 0 
                    %When the small posterior probablities are set to zero,
                    % it's possilble to get a cluster with zero prior.
                    % For cluster with zero prior, we keep its mean and
                    % covariance unchanged in the following iterations.
                    continue;
            end
            post_j = post(:,j)';
            nz_idx = post_j>0;
            S.mu(j,:) = post_j * X / S.PComponents(j);
            
            if sum(nz_idx) < th
                %For efficency, if post_j has less than 40% non-zero values,
                %get centered X corresponding to the observations with those
                %non-zero values for component j.
                Xcentered = X(nz_idx,:) - S.mu(j,:);
                post_j = post_j(nz_idx);
            else
                Xcentered = X - S.mu(j,:);
            end
            
            if CovType == 2
                Xcentered = sqrt(post_j').* Xcentered;
                S.Sigma(:,:,j) = (Xcentered'*Xcentered)/S.PComponents(j) + regVal;
            else % diagonal covariance
                S.Sigma(:,:,j) = post_j * (Xcentered.^2) / S.PComponents(j)+regVal;
            end
        end
    end

    % normalize PComponents
    S.PComponents = S.PComponents/sum(S.PComponents);

end %end iter loop
optimInfo.Iters = iter;
end %function gmcluster_learn

%--------------------------------------------------------------------------
% CHECKINITPARAM - Validate and normalize user-provided initial GMM parameters
%--------------------------------------------------------------------------
function initParam = checkInitParam(initParam,k,d, covtype, sharecov)
if  isfield(initParam, 'ComponentProportion')
   initParam.PComponents= initParam.ComponentProportion;
end

if isfield(initParam, 'PComponents') && ~isempty(initParam.PComponents)
    if  ~isvector(initParam.PComponents) || length(initParam.PComponents) ~= k
        error(message('stats:gmdistribution:MisshapedInitP'));
    elseif any(initParam.PComponents <= 0 )
        error(message('stats:gmdistribution:InvalidP'));
    elseif size(initParam.PComponents,1) ~= 1
        initParam.PComponents = initParam.PComponents';
    end
else
    initParam.PComponents = ones(1,k); %default initial mixing proportions be equal
end

%normalize the mixing proportions
initParam.PComponents = initParam.PComponents/sum (initParam.PComponents);

if isfield(initParam,'mu') && ~isempty(initParam.mu)
    if ~isequal(size(initParam.mu),[k,d])
        error(message('stats:gmdistribution:MisshapedInitMu'));
    end
else
    error(message('stats:gmdistribution:MissingInitMu'));
end

if isfield(initParam,'Sigma') && ~isempty(initParam.Sigma)
    if sharecov || k == 1  % shared covariance or only one component
        if covtype == 1 %diagonal covariance
            if ~isequal (size(initParam.Sigma), [1 d])
                error(message('stats:gmdistribution:MisshapedInitSingleCov'));
            elseif  min(initParam.Sigma) < max(initParam.Sigma) * eps
                error(message('stats:gmdistribution:BadSingleInitCov'));
            end
        else %full covariance
            if ~isequal( size(initParam.Sigma),[d d] )
                error(message('stats:gmdistribution:MisshapedInitSingleCov'));
            end
            [~,err] = cholcov(initParam.Sigma);
            if err ~= 0
                error(message('stats:gmdistribution:BadSingleInitCov'));
            end

        end
    else % different covariance and there are more than one cluster
        if covtype == 1 %diagonal covariance
            if ~isequal(size(initParam.Sigma), [1 d k])
                error(message('stats:gmdistribution:MisshapedInitCov'));
            end
            for j = 1:k
                %check whether the covariance matrix is positive definite
                if  min(initParam.Sigma(:,:,j)) < max(initParam.Sigma(:,:,j)) * eps
                    error(message('stats:gmdistribution:BadInitCov'));
                end
            end
        else % full covariance
            if ~isequal (size(initParam.Sigma),[d d k])
                error(message('stats:gmdistribution:MisshapedInitCov'));
            end
            for j = 1:k
                % Make sure Sigma is a valid covariance matrix
                %check for positive definite
                [~,err] = cholcov(initParam.Sigma(:,:,j));
                if err ~= 0
                    error(message('stats:gmdistribution:BadInitCov'));
                end
            end
        end
    end
else
    error(message('stats:gmdistribution:MissingInitCov'));
end

end %function checkInitParam

%--------------------------------------------------------------------------
% RANDINITPARAM - Initialize GMM parameters by random sampling of K observations
%--------------------------------------------------------------------------
function initPara = randInitParam(X,k, CovType, SharedCov,RegV)
[n,d] = size(X);

initPara.mu = X(randsample(n,k),:);
initPara.PComponents = ones(1,k,'like',X)/k ;% equal mixing proportions
if CovType == 1 %diagonal covariance
    if SharedCov
        initPara.Sigma = var(X) + RegV;
    else
        initPara.Sigma = repmat(var(X) + RegV,[1,1,k]);
    end
else %full covariance
    if SharedCov
        initPara.Sigma = diag(var(X)) + RegV*eye(d,'like',X);
    else
        initPara.Sigma = repmat(diag(var(X)) + RegV*eye(d,'like',X),[1,1,k]);
    end
end

end %function randInitParam

%--------------------------------------------------------------------------
% PLUSINITPARAM - Initialize GMM parameters using k-means++ seeding algorithm
% Uses weighted distance for source reconstruction applications.
%--------------------------------------------------------------------------
function initPara = plusInitParam(X,weight,k, CovType, SharedCov,RegV)

initPara.PComponents = ones(1,k,'like',X)/k ;% equal mixing proportions
initVar  = var(weight.*X) + RegV;
initSigma = diag(initVar);

if CovType == 1 %diagonal covariance
    Sigma = initVar;
else %full covariance matrix
    Sigma = initSigma;
end
if SharedCov
    initPara.Sigma = Sigma;
else
    initPara.Sigma = repmat(Sigma,[1,1,k]);
end

% Select the first seed by sampling uniformly at random
index = zeros(k,1);
[C(1,:), index(1)] = datasample(X,1);
minDist = inf(size(X,1),1);            
% Select the rest of the seeds by a probabilistic model
for ii = 2:k
    minDist = min(minDist,distfun(X,C(ii-1,:),initVar));
    denominator = sum(minDist);
    if denominator==0 || denominator==Inf
        C(ii:k,:) = datasample(X,k-ii+1,1,'Replace',false);
        break;
    end
    sampleProbability = minDist/denominator;             
    [C(ii,:), index(ii)] = datasample(X,1,1,'Replace',false,...
        'Weights',sampleProbability);
end
initPara.mu = C;
end %function plusInitParam

function D = distfun(X, C, var)
% DISTFUN - Compute squared Mahalanobis distance from points to centroid
% C is a row vector (centroid); var is the variance vector for normalization
D = sum(((X-C)./sqrt(var)).^2,2);
end

%--------------------------------------------------------------------------
% PARTINITPARAM - Initialize GMM from a given partition (cluster assignment)
%--------------------------------------------------------------------------
function initPara = partInitParam(X,k,CovType, SharedCov,RegV,initIdx)
[n,d]=size(X);
initPara.mu = zeros(k,d,'like',X);
initPara.PComponents = zeros(1,k,'like',X);

% compute initial mu, Sigma, mixing proportions
initPara.PComponents = histc(initIdx,1:k); %unnormalized mixing proportions
if size(initPara.PComponents,2)==1 %column vector
    initPara.PComponents = initPara.PComponents'; %make sure it is a row vector;
end
if SharedCov
    if CovType == 2 %full covariance
        initPara.Sigma = zeros(d,d,'like',X);
        for j = 1:k
            X0 = X(initIdx == j,:);
            initPara.mu(j,:) = mean(X0);
            X0 = bsxfun(@minus,X0,initPara.mu(j,:));
            initPara.Sigma = initPara.Sigma + X0' * X0;
        end
        initPara.Sigma = initPara.Sigma/n + RegV * eye(d,'like',X);
    else %diagonal covariance
        initPara.Sigma = zeros(1,d,'like',X);
        for j = 1:k
            X0=X(initIdx ==j,:);
            initPara.mu(j,:) = mean(X0);
            X0=bsxfun(@minus,X0,initPara.mu(j,:));
            initPara.Sigma = initPara.Sigma + sum(X0.^2,1);
        end
        initPara.Sigma = initPara.Sigma/n + RegV;
    end
else %different covariance
    if CovType == 2 %%full covariance
        initPara.Sigma=zeros(d,d,k,'like',X);
        for j = 1:k
            X0 = X(initIdx == j,:);
            initPara.mu(j,:) = mean(X0);
            X0 = bsxfun(@minus,X0,initPara.mu(j,:));
            initPara.Sigma(:,:,j) = X0' * X0/initPara.PComponents(j)+ RegV*eye(d,'like',X);
        end
    else % diagonal covariance
        initPara.Sigma = zeros(1,d,k,'like',X);
        for j = 1:k
            X0 = X(initIdx == j,:);
            initPara.mu(j,:) = mean(X0);
            X0 = bsxfun(@minus,X0,initPara.mu(j,:));
            initPara.Sigma(:,:,j) = sum(X0.^2,1)/initPara.PComponents(j) + RegV;
        end
    end
end
initPara.PComponents = initPara.PComponents/n;

end %function getInitParam
