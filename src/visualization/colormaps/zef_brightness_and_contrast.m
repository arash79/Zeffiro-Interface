function colormap_vec = zef_brightness_and_contrast(colormap_vec, brightness_val, contrast_val)
%ZEF_BRIGHTNESS_AND_CONTRAST  Pointwise LUT reshape: ((x+b)/(1+b))^(1+c).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   colormap_vec = zef_brightness_and_contrast(colormap_vec, brightness, contrast)
%
%   Applied after zef_colormap when figure-tool brightness/contrast sliders
%   move. b=0,c=0 is identity. Does not clip to [0,1].
%
%   See also zef_colormap.
colormap_vec = (((colormap_vec + brightness_val)/(1+brightness_val)).^(1+contrast_val));

end
