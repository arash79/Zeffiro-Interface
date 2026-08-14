function new_colormap = zef_update_colormap(colormap_ind, colortune_param, colormap_size)
%ZEF_UPDATE_COLORMAP  Build an RGB LUT from colormap_cell{index}(tune, size).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Figure tool **Colormap:** popup stores an index in zef.update_colormap.
%   Plotters call this (or zef_colormap) to get a size-by-3 array in [0,1].
%   zef.colormap_cell is filled in zef_init: Monterosso, Intensity I–III,
%   Contrast I–V, Blue brain I–III, parcellation, Easter, Greyscale.
%
%   Unlike zef_colormap, tune and size are arguments (not read from zef),
%   so a popped-out axes can pass explicit values. The function name in
%   colormap_cell is eval'd in the base workspace.
%
%   new_colormap = zef_update_colormap(colormap_ind, colortune_param, colormap_size)
%
%   Inputs
%     colormap_ind     - 1-based index into zef.colormap_cell.
%     colortune_param  - scalar band-shape (Figure **Colortune**).
%     colormap_size    - number of RGB rows (zef.colormap_size).
%
%   Output
%     new_colormap  - colormap_size-by-3 RGB.
%
%   See also zef_colormap, zef_update_colorscale.

colormap_cell = evalin('base','zef.colormap_cell');
new_colormap = evalin('base',[colormap_cell{colormap_ind} '(' num2str(colortune_param) ',' num2str(colormap_size) ')']);

end
