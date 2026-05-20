function brightness_val = zef_update_brightness(varargin)
% --- Zeffiro documentation header ---
% zef_update_brightness — Syncs GUI control values into `zef` for brightness.
%
% Purpose:
%   Syncs GUI control values into `zef` for brightness.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   varargin
%
% Outputs:
%   brightness_val
%
% Zef fields (observed):
%   zef.h_axes1 (read)
%   zef.h_update_brightness (read)
%   zef.h_update_colormap (read)
%   zef.update_contrast (read)
%
% Calls (project):
%   zef_brightness_and_contrast
%   zef_colormap
%   zef_update_brightness
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[brightness_val] = zef_update_brightness(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


slider_value_new = evalin('base','zef.h_update_brightness.Value');

if not(isempty(varargin))
    h = varargin{1};
else
    h = evalin('base','zef.h_axes1');
end

if not(isempty(varargin))
    if length(varargin) > 1
        slider_value_new = varargin{1};
    end
end

brightness_val = slider_value_new;

contrast_val = evalin('base','zef.update_contrast');

colormap_ind = evalin('base','zef.h_update_colormap.Value');

colormap_vec = zef_brightness_and_contrast(zef_colormap(colormap_ind), brightness_val, contrast_val);

h.Colormap = colormap_vec;

end
