function zef_logarithmic_distribution(parameter_vec)
% --- Zeffiro documentation header ---
% zef_logarithmic_distribution — Zef logarithmic distribution.
%
% Purpose:
%   Zef logarithmic distribution.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   parameter_vec
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.h_axes1 (read)
%
% Calls (project):
%   zef_logarithmic_distribution
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_logarithmic_distribution(parameter_vec)` with project root and `src` on the path.
% --- End Zeffiro documentation header

axes(evalin('base','zef.h_axes1'));

h_axes = evalin('base','zef.h_axes1');
cla(h_axes,'reset');

parameter_vec = max(1E-30,parameter_vec);
h_hist = histogram(log10(parameter_vec),200);

hist_y = log10(h_hist.Values);
hist_x = 0.5*(h_hist.BinEdges(1:end-1)+h_hist.BinEdges(2:end));

h_plot = plot(hist_x, hist_y,'k');
set(h_plot,'linewidth',1);

set(gca,'xlim',[min(hist_x) max(hist_x)]);
set(gca,'ylim',[min(hist_y) max(hist_y)]);
set(gca,'xgrid','on');
set(gca,'ygrid','on');

end
