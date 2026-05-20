function zef_histogram(parameter_vec)
% --- Zeffiro documentation header ---
% zef_histogram — Zef histogram.
%
% Purpose:
%   Zef histogram.
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
%   zef_histogram
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_histogram(parameter_vec)` with project root and `src` on the path.
% --- End Zeffiro documentation header

axes(evalin('base','zef.h_axes1'));

h_axes = evalin('base','zef.h_axes1');
cla(h_axes,'reset');

h_hist = histogram(log10(parameter_vec),200);
h_hist.FaceColor = [0.5 0.5 0.5];

hist_y = (h_hist.Values);
hist_x = 0.5*(h_hist.BinEdges(1:end-1)+h_hist.BinEdges(2:end));

set(gca,'xlim',[min(hist_x) max(hist_x)]);
set(gca,'ylim',[min(hist_y) max(hist_y)]);
set(gca,'xgrid','on');
set(gca,'ygrid','on');

end
