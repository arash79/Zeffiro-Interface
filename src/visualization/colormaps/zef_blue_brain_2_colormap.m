function [colormap_vec] = zef_blue_brain_2_colormap(colortune_param, colormap_size)
%ZEF_BLUE_BRAIN_2_COLORMAP  colormap_cell{11} "Blue brain II".
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Polynomial RGB of the index 1:size, max-normalize, then .^colortune_param.
%   zef_init colormap_cell{11}; Figure-tool Colormap: item 11.
%   colormap_vec = zef_blue_brain_2_colormap(colortune_param, colormap_size)
colormap_vec = [(colormap_size/5)^3 + (colormap_size)^2*[1 : colormap_size] ; (colormap_size/2)^3 + ((colormap_size)/2)*[1:colormap_size].^2 ; ...
    (0.7*colormap_size)^3+(0.5*colormap_size)^2*[1:colormap_size]];
colormap_vec = colormap_vec'/max(colormap_vec(:));
colormap_vec = colormap_vec.^(colortune_param);

end
