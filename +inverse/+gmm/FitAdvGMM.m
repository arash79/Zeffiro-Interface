function obj = FitAdvGMM(positions, weight, k, varargin)
%FITADVGMM  Weighted EM Gaussian mixture fit on reconstruction samples.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   OBJ = FITADVGMM(POSITIONS, WEIGHT, K) fits K components to POSITIONS
%   (N-by-D) with per-row WEIGHT. Callers: inverse.gmm.ClassGMModeling
%   and zef_AdvGMModeling. Name-value pairs: Start, Replicates,
%   CovarianceType, SharedCovariance, RegularizationValue, Options,
%   ProbabilityTolerance. Delegates to AdvGMModeling4Rec.
%
%   See also inverse.gmm.AdvGMModeling4Rec, inverse.gmm.ClassGMModeling.

import inverse.gmm.*

if nargin > 2
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if nargin < 2
    error(message('stats:gmdistribution:TooFewInputs'));
end

if ~isscalar(k) || ~isnumeric(k) || ~isfinite(k) ...
         || k<1 || k~=round(k)
    error(message('stats:gmdistribution:BadK'));
end

[n, d] = size(positions);
if n <= d
    error('Too few source points in the target space. Consider lowering the reconstruction threshold value from the app''s window or check that the activity is not concentrated to one source position.')
end

if n <= k
    error(message('stats:gmdistribution:TooManyClusters'));
end

if n ~= size(weight,1)
    error('Number of source positions and weights do not match.')
end

pnames = {      'start' 'replicates'  'covariancetype' 'sharedcovariance'  'regularizationvalue'  'options' 'probabilitytolerance'};
dflts =  {      'plus'           1      'full'            false             0                     []         1e-8};
[start,reps, CovType,SharedCov, RegV, options,probtol] ...
    = internal.stats.parseArgs(pnames, dflts, varargin{:});

options = statset(statset('gmdistribution'),options);

if ~isnumeric(reps) || ~isscalar(reps) || round(reps) ~= reps || reps < 1
    error(message('stats:gmdistribution:BadReps'));
end

if ~isnumeric(probtol) || ~isscalar(probtol)|| probtol >1e-6 || probtol<0
    error(message('stats:gmdistribution:BadProbTol'));
end


if ~isnumeric(RegV) || ~isscalar(RegV) || RegV < 0
    error(message('stats:gmdistribution:InvalidReg'));
end

varX = var(weight.*positions) + RegV;
I = find(varX < eps(max(varX)));
if ~isempty(I)
    error(message('stats:gmdistribution:ZeroVariance', num2str( I )));
end

if ischar(CovType)
    covNames = {'diagonal','full'};
    i = find(strncmpi(CovType,covNames,length(CovType)));
    if isempty(i)
        error(message('stats:gmdistribution:UnknownCovType', CovType));
    end
    CovType = i;
else
    error(message('stats:gmdistribution:InvalidCovType'));
end

if ~islogical(SharedCov)
    error(message('stats:gmdistribution:InvalidSharedCov'));
end

options.Display = find(strncmpi(options.Display, {'off','notify','final','iter'},...
    length(options.Display))) - 1;

try
    %========= ACTUAL GMM ===================
    [S,NlogL,optimInfo] =...
        AdvGMModeling4Rec(positions,weight,k,start,reps,CovType,SharedCov,RegV,options,probtol);

    obj.NDimensions = d;
    obj.NComponents = k;
    obj.ComponentProportion = S.PComponents;
    obj.mu = S.mu;
    obj.Sigma = S.Sigma;
    obj.Converged = optimInfo.Converged;
    obj.Iters = optimInfo.Iters;
    obj.NlogL = NlogL;
    obj.SharedCov = SharedCov;
    obj.RegV = RegV;
    obj.ProbabilityTolerance = probtol;
    if CovType == 1
        obj.CovType = 'diagonal';
        if SharedCov
            nParam = obj.NDimensions;
        else
            nParam = obj.NDimensions * k;
        end
    else
        obj.CovType = 'full';
        if SharedCov
            nParam = obj.NDimensions * (obj.NDimensions+1)/2;
        else
            nParam = k*obj.NDimensions * (obj.NDimensions+1)/2;
        end

    end
    nParam = nParam + k-1 + k * obj.NDimensions;
    obj.BIC = 2*NlogL + nParam*log(n);
    obj.AIC = 2*NlogL + 2*nParam;

catch ME
    rethrow(ME) ;
end
