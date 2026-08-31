function weight = EstepWeight(log_lh, post, weight)
%ESTEPWEIGHT  Reweight observations from GMM posteriors (ClassGMM).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Finds exponent alpha in (0,4) that maximises the weighted
%   log-likelihood, then returns weight.^alpha normalised. Called from
%   AdvGMModeling4Rec after each E-step.
%
%   See also inverse.gmm.AdvGMModeling4Rec.
log_lh = sum(post.*log_lh,2);

% Find optimal exponent via 1D optimization
persistent options
if isempty(options)
    options = optimset('Display','off');
end
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
