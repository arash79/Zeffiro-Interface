function zef_segmentation_tool_toggle(zef,h_button)
% --- Zeffiro documentation header ---
% zef_segmentation_tool_toggle — Zef segmentation tool toggle.
%
% Purpose:
%   Zef segmentation tool toggle.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%   h_button
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.h_zeffiro_window_main (read)
%
% Calls (project):
%   zef_segmentation_tool_toggle
%   zef_set_size_change_function
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `zef_segmentation_tool_toggle(zef, h_button)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if isequal(h_button.UserData,1)
    h_button.UserData = 0;
    position_vec = zef.h_zeffiro_window_main.Position;
    position_vec(3) = 0.505*position_vec(3);
else
    h_button.UserData = 1;
    position_vec = zef.h_zeffiro_window_main.Position;
    position_vec(3) = position_vec(3)/0.505;
end

warning off
zef.h_zeffiro_window_main.SizeChangedFcn = '';
zef.h_zeffiro_window_main.Position = position_vec;
zef_set_size_change_function(zef.h_zeffiro_window_main);
warning on

end
