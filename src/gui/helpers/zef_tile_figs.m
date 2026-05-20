%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef_tile_figs(varargin)
% --- Zeffiro documentation header ---
% zef_tile_figs — Zef tile figs.
%
% Purpose:
%   Zef tile figs.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   varargin
%
% Outputs:
%   See function signature and code below.
%
% Calls (project):
%   zef_tile_figs
%
% Side effects:
%   - base/caller workspace
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_tile_figs(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


n_tiles = 20;
h_aux = evalin('base','findall(groot, ''Type'',''figure'',''Name'',''ZEFFIRO Interface: Figure tool'')');
tile_mat = [1 : n_tiles];
tile_mat = tile_mat'*tile_mat;
for i = 1 : n_tiles
    tile_mat(i,i+1:end) = Inf;
    tile_mat(3*i+1:end,i) = Inf;
end
tile_mat(find(tile_mat < length(h_aux))) = Inf;
[~, tile_mat_ind] = min(abs(tile_mat(:)-length(h_aux)));
[n_1,n_2] = ind2sub(size(tile_mat),tile_mat_ind);
[position_grid_1, position_grid_2] = meshgrid(linspace(0,1-1/n_1,n_1),linspace(0,1-1/n_2,n_2));
for i = 1 : length(h_aux)
    set(h_aux(i),'position',[position_grid_1(i) position_grid_2(i) 1/n_1 1/n_2])
    evalin('base',get(h_aux(i),'SizeChangedFcn'))
end

end
