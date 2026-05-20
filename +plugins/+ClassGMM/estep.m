function [ll, post, logpdf] = estep(log_lh, prob_th)
% --- Zeffiro documentation header ---
% plugins.ClassGMM.estep — Estep.
%
% Purpose:
%   Estep.
%   Folder: Namespaced algorithm support (e.g. ClassGMM, ClassKF) used by GUI plugins and class inverters.
%
% Inputs:
%   log_lh
%   prob_th
%
% Outputs:
%   ll
%   post
%   logpdf
%
% Calls (project):
%   plugins.ClassGMM.estep
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[ll, post, logpdf]] = plugins.ClassGMM.estep(log_lh, prob_th)` with project root and `src` on the path.
% --- End Zeffiro documentation header

%ESTEP E-step for Gaussian mixture model (posterior computation).
%
%   [LL, POST] = ESTEP(LOG_LH) computes the E-step of the EM algorithm for
%   a Gaussian mixture model. LOG_LH is an N-by-K matrix where LOG_LH(i,j)
%   is log(alpha_j * p(x_i | theta_j)), i.e., the log of the component
%   conditional density weighted by the mixing proportion.
%
%   Inputs:
%     LOG_LH  - N-by-K matrix of log component densities (weighted by priors)
%     PROB_TH - (Optional) Posterior probability threshold; values below this
%               are set to zero for numerical stability. Default: none.
%
%   Outputs:
%     LL     - Scalar, total log-likelihood of the data
%     POST   - N-by-K matrix; POST(i,j) = P(component j | observation i)
%     LOGPDF - (Optional) N-by-1 vector of log mixture densities at each point
%
%   Copyright 2007-2016 The MathWorks, Inc.

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
