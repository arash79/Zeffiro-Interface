function zef_reset_color_sliders
%ZEF_RESET_COLOR_SLIDERS  Zero figure-tool colorscale min/max sliders.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Sets zef.colorscale_min_slider / colorscale_max_slider and the
%   matching h_* widget Values to 0 in the base workspace. Does not
%   touch brightness or contrast.


evalin('base','zef.colorscale_min_slider = 0;');
evalin('base','zef.colorscale_max_slider = 0;');
evalin('base','zef.h_colorscale_min_slider.Value = 0;');
evalin('base','zef.h_colorscale_max_slider.Value = 0;');

end
