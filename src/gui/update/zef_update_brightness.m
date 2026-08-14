function brightness_val = zef_update_brightness(varargin)
%ZEF_UPDATE_BRIGHTNESS  Apply **Brightness:** alone (split helper; Figure tool does not call this).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Reads zef.h_update_brightness.Value and zef.update_contrast, rebuilds
%   zef.h_axes1 (or varargin{1}) Colormap via zef_brightness_and_contrast
%   / zef_colormap. If two varargin are passed, the first is treated as
%   the slider value (not an axes handle) — that branch is historical.
%   The Figure-tool sliders call zef_update_contrast_and_brightness.
%
%   brightness_val = zef_update_brightness
%   brightness_val = zef_update_brightness(h_axes)
%
%   See also zef_update_contrast_and_brightness, zef_update_contrast.
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
