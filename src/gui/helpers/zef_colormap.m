function colormap_vec = zef_colormap(inv_colormap)
% --- Zeffiro documentation header ---
% zef_colormap — Zef colormap.
%
% Purpose:
%   Zef colormap.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   inv_colormap
%
% Outputs:
%   colormap_vec
%
% Zef fields (observed):
%   zef.colormap_cell (read)
%   zef.colormap_size (read)
%   zef.colortune_param (read)
%
% Calls (project):
%   zef_colormap
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[colormap_vec] = zef_colormap(inv_colormap)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
