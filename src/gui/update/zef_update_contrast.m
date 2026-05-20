function contrast_val = zef_update_contrast(varargin)
% --- Zeffiro documentation header ---
% zef_update_contrast — Syncs GUI control values into `zef` for contrast.
%
% Purpose:
%   Syncs GUI control values into `zef` for contrast.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   varargin
%
% Outputs:
%   contrast_val
%
% Zef fields (observed):
%   zef.h_axes1 (read)
%   zef.h_update_colormap (read)
%   zef.h_update_contrast (read)
%   zef.update_brightness (read)
%
% Calls (project):
%   zef_brightness_and_contrast
%   zef_colormap
%   zef_update_contrast
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[contrast_val] = zef_update_contrast(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


slider_value_new = evalin('base','zef.h_update_contrast.Value');

if not(isempty(varargin))
    h = varargin{1};
else
    h = evalin('base','zef.h_axes1');
end

if not(isempty(varargin))
    if length(varargin) > 1
        slider_value_new = varargin{2};
    end
end

contrast_val = slider_value_new;

brightness_val = evalin('base','zef.update_brightness');
colormap_ind = evalin('base','zef.h_update_colormap.Value');

colormap_vec = zef_brightness_and_contrast(zef_colormap(colormap_ind), brightness_val, contrast_val);

h.Colormap = colormap_vec;

end
