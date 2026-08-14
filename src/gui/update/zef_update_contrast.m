function contrast_val = zef_update_contrast(varargin)
%ZEF_UPDATE_CONTRAST  Apply **Contrast:** alone (split helper; Figure tool does not call this).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Reads zef.h_update_contrast.Value (or varargin{2}) and
%   zef.update_brightness, rebuilds zef.h_axes1 (or varargin{1}) Colormap
%   via zef_brightness_and_contrast / zef_colormap. The Figure-tool
%   **Contrast:** / **Brightness:** Callbacks call
%   zef_update_contrast_and_brightness instead.
%
%   contrast_val = zef_update_contrast
%   contrast_val = zef_update_contrast(h_axes)
%   contrast_val = zef_update_contrast(h_axes, slider_value)
%
%   See also zef_update_contrast_and_brightness, zef_update_brightness.
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
