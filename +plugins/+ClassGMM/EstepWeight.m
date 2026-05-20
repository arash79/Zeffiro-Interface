function weight = EstepWeight(log_lh, post, weight)
%ESTEPWEIGHT Update observation weights for weighted GMM E-step.
%
%   WEIGHT = ESTEPWEIGHT(LOG_LH, POST, WEIGHT) computes an optimal exponent
%   alpha such that weight.^alpha maximizes the weighted log-likelihood of
%   the current GMM fit. This extension enables weighted GMM fitting for
%   brain source reconstruction, where weights represent source intensities.
%
%   Inputs:
%     LOG_LH - N-by-K matrix of log component densities (from WeightedCondDensity)
%     POST   - N-by-K matrix of posterior probabilities (from estep)
%     WEIGHT - N-by-1 vector of current observation weights
%
%   Output:
%     WEIGHT - Updated N-by-1 weight vector (normalized to sum to 1)
%
%   The exponent alpha is found by maximizing sum(weight.^alpha .* log_lh_marg)
%   over alpha in [0, 4], where log_lh_marg is the marginal log-density.

% Marginal log-likelihood contribution per observation
log_lh = sum(post.*log_lh,2);

% Find optimal exponent via 1D optimization
options = optimset('Display','off');
alpha = fminbnd(@(s) target_fun(s, weight, log_lh), 0, 4, options);

% Apply exponent and renormalize
weight = weight.^alpha;
weight = weight/sum(weight);
end

function val = target_fun(s, weight, p)
% TARGET_FUN - Negative weighted log-likelihood for exponent search
weight = weight.^s;
weight = weight/sum(weight);
val = -sum(weight.*p, 1);
end



