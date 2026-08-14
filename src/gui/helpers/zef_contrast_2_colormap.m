function [colormap_vec] = zef_contrast_2_colormap(colortune_param, colormap_size)
%ZEF_CONTRAST_2_COLORMAP  colormap_cell{6} "Contrast II" (green-weighted).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Four-band mix like Contrast I; first row uses floor(size/2) as well
%   as the colortune_param edges. zef_init colormap_cell{6}; Figure-tool
%   Colormap: item 6.
%   colormap_vec = zef_contrast_2_colormap(colortune_param, colormap_size)
c_aux_1 = floor(colortune_param*colormap_size/3);
c_aux_2 = floor(colormap_size - colortune_param*colormap_size/3);
c_aux_3 = floor(colormap_size/2);
colormap_vec = [([20*[c_aux_3:-1:1] zeros(1,colormap_size-c_aux_3)]); ([15*(colormap_size/3)*[1: c_aux_1]/c_aux_1 15*(colormap_size/3)*[c_aux_2-c_aux_1:-1:1]/(c_aux_2-c_aux_1) zeros(1,colormap_size-c_aux_2)]) ; ([zeros(1,c_aux_1) 7*(colormap_size/3)*[1:c_aux_2-c_aux_1]/(c_aux_2-c_aux_1) 7*(colormap_size/3)*[colormap_size-c_aux_2:-1:1]/(colormap_size-c_aux_2)]);([zeros(1,c_aux_2) 10.5*(colormap_size/3)*[1:colormap_size-c_aux_2]/(colormap_size-c_aux_2)])];
colormap_vec(3,:) = colormap_vec(4,:) + colormap_vec(3,:);
colormap_vec(2,:) = colormap_vec(4,:) + colormap_vec(2,:);
colormap_vec(1,:) = colormap_vec(4,:) + colormap_vec(1,:);
colormap_vec = colormap_vec'/max(colormap_vec(:));
colormap_vec = flipud(colormap_vec);
colormap_vec = colormap_vec(:,1:3);

end
