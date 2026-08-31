function colormap_vec = zef_colormap(inv_colormap)
%ZEF_COLORMAP  Evaluate the LUT named by zef.colormap_cell{inv_colormap}.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   colormap_vec = zef_colormap(inv_colormap)
%
%   inv_colormap is a 1-based index into zef.colormap_items /
%   zef.colormap_cell (set in zef_init). Figure-tool popup **Colormap:**
%   stores zef.update_colormap as that index. This function evals
%
%     colormap_cell{k}(zef.colortune_param, zef.colormap_size)
%
%   and returns size-by-3 RGB in [0,1]. zef is taken from the caller
%   workspace if present, else base.
%
%   Indices (zef_init): 1 Monterosso, 2–4 Intensity I–III, 5–9 Contrast
%   I–V, 10–12 Blue brain I–III, 13 Parcellation (src/parcellation),
%   14 Easter, 15 Greyscale.
%
%   See also zef_brightness_and_contrast, zef_init.
if isequal(evalin('caller','exist(''zef'')'),1)
    zef = evalin('caller','zef');
else
    zef = evalin('base','zef');
end

colortune_param = eval('zef.colortune_param');
colormap_size = eval('zef.colormap_size');
colormap_cell = eval('zef.colormap_cell');
colormap_vec = eval([colormap_cell{inv_colormap} '(' num2str(colortune_param) ',' num2str(colormap_size) ')']);

end
