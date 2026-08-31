function [colormap_vec] = zef_contrast_3_colormap(colortune_param, colormap_size)
%ZEF_CONTRAST_3_COLORMAP  colormap_cell{7} "Contrast III" (red-weighted).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Three-row mix; band edge floor(size - param*size/2). Swap channels
%   1↔2 then fold later bands into red. zef_init colormap_cell{7};
%   Figure-tool Colormap: item 7.
%   colormap_vec = zef_contrast_3_colormap(colortune_param, colormap_size)
c_aux_1 = floor(colormap_size - colortune_param*colormap_size/2);
colormap_vec = [10*(colormap_size/3)*[c_aux_1:-1:1]/c_aux_1 zeros(1,colormap_size-c_aux_1); 3*(colormap_size/3)*[1: c_aux_1]/c_aux_1 3*(colormap_size/3)*[colormap_size-c_aux_1:-1:1]/(colormap_size-c_aux_1); zeros(1,c_aux_1) 3.8*(colormap_size/3)*[1:colormap_size-c_aux_1]/(colormap_size-c_aux_1)];
colormap_vec([1 2],:) = colormap_vec([2 1],:);
colormap_vec(1,:) = colormap_vec(1,:) + colormap_vec(2,:);
colormap_vec(1,:) = colormap_vec(3,:) + colormap_vec(1,:);
colormap_vec(2,:) = colormap_vec(3,:) + colormap_vec(2,:);
colormap_vec = colormap_vec'/max(colormap_vec(:));
colormap_vec = flipud(colormap_vec);

end
