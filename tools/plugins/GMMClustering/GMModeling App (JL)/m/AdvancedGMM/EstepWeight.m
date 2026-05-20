function weight = EstepWeight(log_lh,post,weight)
% --- Zeffiro documentation header ---
% EstepWeight — Estep Weight.
%
% Purpose:
%   Estep Weight.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   log_lh
%   post
%   weight
%
% Outputs:
%   weight
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[weight] = EstepWeight(log_lh, post, weight)` with project root and `src` on the path.
% --- End Zeffiro documentation header


log_lh = sum(post.*log_lh,2);

options = optimset('Display','off');
alpha = fminbnd(@(s) target_fun(s,weight,log_lh),0,4,options);
%disp(num2str(alpha))
weight = weight.^alpha;
weight = weight/sum(weight);
end

%%

function val = target_fun(s,weight,p)

weight = weight.^s;
weight = weight/sum(weight);
val = -sum(weight.*p,1);

end
