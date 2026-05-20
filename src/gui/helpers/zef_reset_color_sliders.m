% --- Zeffiro documentation header ---
% function zef_reset_color_sliders — Function zef reset color sliders.
%
% Purpose:
%   Function zef reset color sliders.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.colorscale_max_slider (read, write)
%   zef.colorscale_min_slider (read, write)
%   zef.h_colorscale_max_slider (read)
%   zef.h_colorscale_min_slider (read)
%
% Calls (project):
%   zef_reset_color_sliders
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function zef_reset_color_sliders` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function zef_reset_color_sliders


evalin('base','zef.colorscale_min_slider = 0;');
evalin('base','zef.colorscale_max_slider = 0;');
evalin('base','zef.h_colorscale_min_slider.Value = 0;');
evalin('base','zef.h_colorscale_max_slider.Value = 0;');

end
