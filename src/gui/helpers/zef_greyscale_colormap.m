function [colormap_vec] = zef_greyscale_colormap(colortune_param, colormap_size)
% --- Zeffiro documentation header ---
% zef_greyscale_colormap — Zef greyscale colormap.
%
% Purpose:
%   Zef greyscale colormap.
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
%   zef_greyscale_colormap
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[colormap_vec] = zef_greyscale_colormap(colortune_param, colormap_size)` with project root and `src` on the path.
% --- End Zeffiro documentation header


t = linspace(0.15,0.95,colormap_size)';
colormap_vec = repmat(t.^colortune_param,1,3);

end
