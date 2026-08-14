function [contrast_val, brightness_val] = zef_update_contrast(varargin)
%ZEF_UPDATE_CONTRAST_AND_BRIGHTNESS  Figure-tool **Contrast:** / **Brightness:** sliders.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Filename is zef_update_contrast_and_brightness.m; the primary function
%   name inside the file is zef_update_contrast (MATLAB still dispatches
%   on the filename). Both sliders' Callbacks call this file, not the
%   split helpers zef_update_contrast.m / zef_update_brightness.m.
%
%   Finds Tag='update_contrast_slider' (range -1..1), Tag=
%   'update_brightness_slider' (range 0..5), and Tag='colormapselection'
%   on the Figure tool (or varargin{1}). Rebuilds axes1 Colormap as
%   zef_brightness_and_contrast(zef_colormap(index), b, c) with
%   ((x+b)/(1+b))^(1+c). Does not rewrite zef.update_* itself; the
%   Callback assigns both returned values.
%
%   [contrast_val, brightness_val] = zef_update_contrast_and_brightness
%   [contrast_val, brightness_val] = zef_update_contrast_and_brightness(h_figure)
%
%   See also zef_update_contrast, zef_update_brightness, zef_brightness_and_contrast.
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
