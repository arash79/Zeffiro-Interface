function weight = EstepWeight(log_lh, post, weight)
% --- Zeffiro documentation header ---
% plugins.ClassGMM.EstepWeight — Estep Weight.
%
% Purpose:
%   Estep Weight.
%   Folder: Namespaced algorithm support (e.g. ClassGMM, ClassKF) used by GUI plugins and class inverters.
%
% Inputs:
%   log_lh
%   post
%   weight
%
% Outputs:
%   weight
%
% Calls (project):
%   plugins.ClassGMM.EstepWeight
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[weight] = plugins.ClassGMM.EstepWeight(log_lh, post, weight)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
