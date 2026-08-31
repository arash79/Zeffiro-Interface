function [colormap_vec] = zef_blue_brain_3_colormap(colortune_param, colormap_size)
%ZEF_BLUE_BRAIN_3_COLORMAP  colormap_cell{12} "Blue brain III".
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Linear RGB [1:n; 0.5*(1:n); 0.5*(n:-1:1)] + 1, max-normalize, .^param.
%   zef_init colormap_cell{12}; Figure-tool Colormap: item 12.
%   colormap_vec = zef_blue_brain_3_colormap(colortune_param, colormap_size)
colormap_vec = [[1:colormap_size] ; 0.5*[1:colormap_size] ; 0.5*[colormap_size:-1:1] ];
colormap_vec = colormap_vec + 1;
colormap_vec = colormap_vec'/max(colormap_vec(:));
colormap_vec = colormap_vec.^(colortune_param);

end
