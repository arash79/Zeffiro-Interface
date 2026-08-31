function [colormap_vec] = zef_greyscale_colormap(colortune_param, colormap_size)
%ZEF_GREYSCALE_COLORMAP  colormap_cell{15} "Greyscale".
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   colormap_vec = zef_greyscale_colormap(colortune_param, colormap_size)
%
%   repmat(linspace(0.15,0.95,size)'.^colortune_param, 1, 3). param=1 is
%   linear grey; >1 darkens the low end.
t = linspace(0.15,0.95,colormap_size)';
colormap_vec = repmat(t.^colortune_param,1,3);

end
