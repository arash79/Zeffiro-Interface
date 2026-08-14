function [colormap_vec] = zef_blue_brain_1_colormap(colortune_param, colormap_size)
%ZEF_BLUE_BRAIN_1_COLORMAP  colormap_cell{10} "Blue brain I".
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   colormap_vec = zef_blue_brain_1_colormap(colortune_param, colormap_size)
%
%   Piecewise RGB split at floor(size/2), then log(2*x/param^4+1),
%   max-normalize, flipud.
c_aux_1 = floor(colormap_size/2);
colormap_vec = [[c_aux_1:-1:1]/c_aux_1 zeros(1,colormap_size-c_aux_1); ...
    [1:c_aux_1]/c_aux_1 [colormap_size-c_aux_1:-1:1]/(colormap_size-c_aux_1); ...
    zeros(1,c_aux_1) [1:colormap_size-c_aux_1]/(colormap_size - c_aux_1)];
colormap_vec =  log(2*colormap_vec./colortune_param.^4+1);
colormap_vec = colormap_vec'/max(colormap_vec(:));
colormap_vec = flipud(colormap_vec);



end
