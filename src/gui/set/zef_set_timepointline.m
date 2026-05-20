function zef_set_timepointline(h_axes)
% --- Zeffiro documentation header ---
% zef_set_timepointline — Zef set timepointline.
%
% Purpose:
%   Zef set timepointline.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   h_axes
%
% Outputs:
%   See function signature and code below.
%
% Calls (project):
%   zef_set_timepointline
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_set_timepointline(h_axes)` with project root and `src` on the path.
% --- End Zeffiro documentation header


h_line = findobj(h_axes.Children,'Tag','timepointline');
delete(h_line);
h_line = line(h_axes.CurrentPoint([1 1]),[h_axes.YLim]);
h_line.Color = 0.5*[1 1 1];
h_line.Tag = 'timepointline';
h_axes.Title.String = ['Time value = ' num2str(h_axes.CurrentPoint(1))];
h_line.LineWidth = 1;

end
