% --- Zeffiro documentation header ---
% function zef_plot_condition — Function zef plot condition.
%
% Purpose:
%   Function zef plot condition.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.h_axes1 (read)
%   zef.nodes (read)
%   zef.tetra (read)
%
% Calls (project):
%   zef_condition_number
%   zef_plot_condition
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function zef_plot_condition` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function zef_plot_condition


axes(evalin('base','zef.h_axes1'));

h_axes = evalin('base','zef.h_axes1');

condition_number = zef_condition_number(evalin('base','zef.nodes'), evalin('base','zef.tetra'));
condition_number = max(1E-30,condition_number);
h_hist = histogram(log10(condition_number),10000);

hist_y = log10(h_hist.Values);
hist_x = 0.5*(h_hist.BinEdges(1:end-1)+h_hist.BinEdges(2:end));

h_plot = plot(h_axes, hist_x, hist_y,'k');
set(h_plot,'linewidth',1);

set(gca,'xlim',[log10(min(condition_number)) log10(max(condition_number))]);
set(gca,'ylim',[min(hist_y) max(hist_y)]);
set(gca,'xgrid','on');
set(gca,'ygrid','on');

end
