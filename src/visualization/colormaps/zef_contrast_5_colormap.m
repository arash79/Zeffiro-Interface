function [colormap_vec] = zef_contrast_5_colormap(colortune_param, colormap_size)
%ZEF_CONTRAST_5_COLORMAP  colormap_cell{9} "Contrast V" (cool / cyan-blue).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Same band edge as Contrast III/IV; fold the third row into R and G,
%   then add 100 before max-normalize (compresses the low end).
%   colormap_vec = zef_contrast_5_colormap(colortune_param, colormap_size)
c_aux_1 = floor(colormap_size - colortune_param*colormap_size/2);
colormap_vec = [10*(colormap_size/3)*[c_aux_1:-1:1]/c_aux_1 zeros(1,colormap_size-c_aux_1); 2*(colormap_size/3)*[1: c_aux_1]/c_aux_1 2*(colormap_size/3)*[colormap_size-c_aux_1:-1:1]/(colormap_size-c_aux_1); zeros(1,c_aux_1) 3.8*(colormap_size/3)*[1:colormap_size-c_aux_1]/(colormap_size-c_aux_1)];
colormap_vec(1,:) = colormap_vec(3,:) + colormap_vec(1,:);
colormap_vec(2,:) = colormap_vec(3,:) + colormap_vec(2,:);
colormap_vec = colormap_vec+100;
colormap_vec = colormap_vec'/max(colormap_vec(:));
colormap_vec = flipud(colormap_vec);

end
