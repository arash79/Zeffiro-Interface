function zef_set_linear_colorbar_ticks(zef,n_ticks,n_digits,max_val)
% --- Zeffiro documentation header ---
% zef_set_linear_colorbar_ticks — Zef set linear colorbar ticks.
%
% Purpose:
%   Zef set linear colorbar ticks.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%   n_ticks
%   n_digits
%   max_val
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.h_zeffiro (read)
%
% Calls (project):
%   zef_set_linear_colorbar_ticks
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_set_linear_colorbar_ticks(zef, n_ticks, n_digits, max_val)` with project root and `src` on the path.
% --- End Zeffiro documentation header


h_c = findobj(zef.h_zeffiro.Children,'Tag','rightColorbar');

h_c.Ticks = linspace(h_c.Limits(1),h_c.Limits(2),n_ticks);
TicksLabels = round(max_val.*10.^((h_c.Ticks - h_c.Limits(2))./20),n_digits);
h_c.TickLabels = cellstr(num2str(TicksLabels(:)));


end
