function [contrast_val, brightness_val] = zef_update_contrast(varargin)
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
%   brightness_val
%
% Zef fields (observed):
%   zef.h_zeffiro (read)
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
%   Programmatic: `[[contrast_val, brightness_val]] = zef_update_contrast(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if isequal(evalin('caller','exist(''zef'')'),1)
    zef = evalin('caller','zef');
else
    zef = evalin('base','zef');
end

if not(isempty(varargin))
    h_figure = varargin{1};
else
    h_figure = eval('zef.h_zeffiro');
end

h = findobj(get(h_figure,'Children'),'Tag','axes1');
h_object_1 = findobj(get(h_figure,'Children'),'Tag','update_contrast_slider');
h_object_2 = findobj(get(h_figure,'Children'),'Tag','update_brightness_slider');
h_object_3 = findobj(get(h_figure,'Children'),'Tag','colormapselection');
if isempty(h_object_1)
    h_figure = eval('zef.h_zeffiro');
    h_object_1 = findobj(get(h_figure,'Children'),'Tag','update_contrast_slider');
    h_object_2 = findobj(get(h_figure,'Children'),'Tag','update_brightness_slider');
    h_object_3 = findobj(get(h_figure,'Children'),'Tag','colormapselection');
end

slider_value_new = h_object_1.Value;

contrast_val = slider_value_new;

brightness_val = h_object_2.Value;
colormap_ind = h_object_3.Value;

colormap_vec = zef_brightness_and_contrast(zef_colormap(colormap_ind), brightness_val, contrast_val);

h.Colormap = colormap_vec;

end
