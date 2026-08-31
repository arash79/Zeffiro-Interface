function [ll, post, logpdf] = estep(log_lh, prob_th)
%ESTEP  GMM E-step: posteriors and log-likelihood from log component densities.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   LOG_LH is N-by-K log(alpha_j * p(x_i | theta_j)).
%   Outputs: ll (sum of log marginal densities), post (N-by-K responsibilities),
%   logpdf (N-by-1 log p(x_i)). Optional PROB_TH zeros small posteriors then
%   renormalizes. Called from AdvGMModeling4Rec.
%
%   See also inverse.gmm.AdvGMModeling4Rec.

% Subtract row maximum to avoid numerical underflow in exp()
maxll = max(log_lh,[],2);
post = exp(log_lh-maxll);
density = sum(post,2);
logpdf = log(density) + maxll;
ll = sum(logpdf);
post = post./density;  % Normalize to obtain valid posterior probabilities

% Optionally threshold small posteriors for efficiency (used during fitting)
if nargin > 1
    post(post < prob_th) = 0;
    density = sum(post,2);
    post = post./density;  % Renormalize after thresholding
end
