function zef_tile_figs(varargin)
%ZEF_TILE_FIGS  Tile every "ZEFFIRO Interface: Figure tool" window.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Finds those figures by Name (not zef_arrange_windows). Chooses an n1×n2
%   grid whose product is at least the figure count (n_tiles cap 20),
%   standalone-undocks each, and sets normalized Position. varargin unused.
%   Not the **Window → Reset windows** path.
%
%   See also zef_arrange_windows, zef_window_manager.

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
    zef_window_manager('standalone', h_aux(i));
    set(h_aux(i),'position',[position_grid_1(i) position_grid_2(i) 1/n_1 1/n_2])
    zef_window_manager('sizechanged', h_aux(i));
end

end
