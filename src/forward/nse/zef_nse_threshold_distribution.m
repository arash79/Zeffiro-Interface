function d = zef_nse_threshold_distribution(d,quantile_min,quantile_max)
% --- Zeffiro documentation header ---
% zef_nse_threshold_distribution — Zef nse threshold distribution.
%
% Purpose:
%   Zef nse threshold distribution.
%   Folder: Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.
%
% Inputs:
%   d
%   quantile_min
%   quantile_max
%
% Outputs:
%   d
%
% Calls (project):
%   zef_nse_threshold_distribution
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[d] = zef_nse_threshold_distribution(d, quantile_min, quantile_max)` with project root and `src` on the path.
% --- End Zeffiro documentation header


a = quantile(abs(d),quantile_min);
b = quantile(abs(d),quantile_max);
d(find(abs(d)<a))=a;
d(find(abs(d)>b))=b;

end
