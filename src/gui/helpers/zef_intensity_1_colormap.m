function [colormap_vec] = zef_intensity_1_colormap(colortune_param, colormap_size)
%ZEF_INTENSITY_1_COLORMAP  colormap_cell{2} "Intensity I" (red-led ramps).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   colormap_vec = zef_intensity_1_colormap(colortune_param, colormap_size)
%
%   Channel 1 is a full-length ramp; 2 and 3 cut at the usual
%   colortune_param band edges. flipud, then add 0.2*(size:-1:1)/size to
%   all channels and re-normalize. Intensity II/III swap which channel
%   gets the long ramp (green / blue).
c_aux_1 = floor(colortune_param*colormap_size/3);
c_aux_2 = floor(colormap_size  - colortune_param*colormap_size/3);
colormap_vec = zeros(3,colormap_size);
colormap_vec(1,:) =10*([colormap_size:-1:1]/colormap_size);
colormap_vec(2,:) = [10*(3*(1  - 1/3)/(2*(1- colortune_param/3)))*[c_aux_2:-1:1]/colormap_size zeros(1,colormap_size-c_aux_2)];
colormap_vec(3,:) = [10*((3/colortune_param)*[c_aux_1:-1:1]/colormap_size) zeros(1,colormap_size-c_aux_1)];
colormap_vec = colormap_vec'/max(colormap_vec(:));
colormap_vec = flipud(colormap_vec);
colormap_vec = colormap_vec + repmat(0.2*([colormap_size:-1:1]'/colormap_size),1,3);
colormap_vec = colormap_vec/max(colormap_vec(:));

end
