function [colormap_vec] = zef_blue_brain_1_colormap(colortune_param, colormap_size)
% --- Zeffiro documentation header ---
% zef_blue_brain_1_colormap — Zef blue brain 1 colormap.
%
% Purpose:
%   Zef blue brain 1 colormap.
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
%   zef_blue_brain_1_colormap
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[colormap_vec] = zef_blue_brain_1_colormap(colortune_param, colormap_size)` with project root and `src` on the path.
% --- End Zeffiro documentation header



c_aux_1 = floor(colormap_size/2);
colormap_vec = [[c_aux_1:-1:1]/c_aux_1 zeros(1,colormap_size-c_aux_1); ...
    [1:c_aux_1]/c_aux_1 [colormap_size-c_aux_1:-1:1]/(colormap_size-c_aux_1); ...
    zeros(1,c_aux_1) [1:colormap_size-c_aux_1]/(colormap_size - c_aux_1)];
colormap_vec =  log(2*colormap_vec./colortune_param.^4+1);
colormap_vec = colormap_vec'/max(colormap_vec(:));
colormap_vec = flipud(colormap_vec);



end
