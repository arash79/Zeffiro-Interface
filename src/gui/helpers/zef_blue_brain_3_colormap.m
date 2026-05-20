function [colormap_vec] = zef_blue_brain_3_colormap(colortune_param, colormap_size)
% --- Zeffiro documentation header ---
% zef_blue_brain_3_colormap — Zef blue brain 3 colormap.
%
% Purpose:
%   Zef blue brain 3 colormap.
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
%   zef_blue_brain_3_colormap
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[colormap_vec] = zef_blue_brain_3_colormap(colortune_param, colormap_size)` with project root and `src` on the path.
% --- End Zeffiro documentation header


colormap_vec = [[1:colormap_size] ; 0.5*[1:colormap_size] ; 0.5*[colormap_size:-1:1] ];
colormap_vec = colormap_vec + 1;
colormap_vec = colormap_vec'/max(colormap_vec(:));
colormap_vec = colormap_vec.^(colortune_param);

end
