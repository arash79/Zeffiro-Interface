function [colormap_vec] = zef_blue_brain_2_colormap(colortune_param, colormap_size)
% --- Zeffiro documentation header ---
% zef_blue_brain_2_colormap — Zef blue brain 2 colormap.
%
% Purpose:
%   Zef blue brain 2 colormap.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   colortune_param
%   colormap_size
%
% Outputs:
%   colormap_vec
%
% Calls (project):
%   zef_blue_brain_2_colormap
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[colormap_vec] = zef_blue_brain_2_colormap(colortune_param, colormap_size)` with project root and `src` on the path.
% --- End Zeffiro documentation header


colormap_vec = [(colormap_size/5)^3 + (colormap_size)^2*[1 : colormap_size] ; (colormap_size/2)^3 + ((colormap_size)/2)*[1:colormap_size].^2 ; ...
    (0.7*colormap_size)^3+(0.5*colormap_size)^2*[1:colormap_size]];
colormap_vec = colormap_vec'/max(colormap_vec(:));
colormap_vec = colormap_vec.^(colortune_param);

end
