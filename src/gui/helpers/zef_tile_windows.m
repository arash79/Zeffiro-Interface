%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef_arrange_windows(varargin)
%ZEF_TILE_WINDOWS  Stale copy of window tiling; prefer src/core/zef_arrange_windows.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Filename zef_tile_windows.m (MATLAB calls this file by that name). The
%   first function line is still named zef_arrange_windows. No first-party
%   caller: **Window → Tile / Maximize / Minimize / Close** in
%   zef_menu_tool uses src/core/zef_arrange_windows. Keep this file only
%   as a historical duplicate.
%
%   Unlike the core copy, varargin{1} is stored as arrange_function and
%   never read. Collecting handles and applying tile/max/min all key off
%   arrange_mode (varargin{3}, default 'on-screen'). Collecting runs only
%   for 'on-screen' or 'all'; tiling runs only for 'tile'. Those sets are
%   disjoint, so a single call cannot both find windows and tile them.
%   Maximize here sets WindowState to 'normal' (not 'maximized'). There is
%   no 'close' branch, no zef_window_manager('is_protected') skip, and no
%   post-tile dock_menu.
%
%   zef_tile_windows
%   zef_tile_windows(unused_arrange_function)
%   zef_tile_windows(unused_arrange_function, arrange_target)
%   zef_tile_windows(unused_arrange_function, arrange_target, arrange_mode)
%
%   Inputs (parsed, but see the arrange_mode collision above)
%     unused_arrange_function - ignored (core uses this as 'tile'|…).
%     arrange_target          - 'windows' (default), 'figs', or 'tools'.
%     arrange_mode            - 'on-screen' (default), 'all', 'tile',
%                               'maximize', or 'minimize'.
%
%   See also zef_arrange_windows, zef_tile_figs.

arrange_mode = 'on-screen';
arrange_target = 'windows';
arrange_function = 'tile';

if not(isempty(varargin))
    arrange_function = varargin{1}; % stored but never used; core uses this as the action

    if length(varargin) > 1
        arrange_target = varargin{2};
    end

    if length(varargin) > 2
        arrange_mode = varargin{3};
    end

end
n_tiles = 20;
h_aux = [];

if isequal(arrange_mode,'on-screen')
    if isequal(arrange_target,'windows')
        h_aux = evalin('base','findall(groot,''-regexp'',''Name'',''ZEFFIRO Interface:*'',''WindowState'',''normal'')');
    elseif isequal(arrange_target,'figs')
        h_aux = evalin('base','findall(groot,''-regexp'',''Name'',''ZEFFIRO Interface: Figure tool*'',''WindowState'',''normal'')');
    elseif isequal(arrange_target,'tools')
        h_aux = evalin('base','findall(groot,''Name'',''ZEFFIRO Interface:*'',''-not'',''-regexp'',''Name'',''ZEFFIRO Interface: Figure tool*'',''WindowState'',''normal'')');
    end
elseif isequal(arrange_mode,'all')
    if isequal(arrange_target,'windows')
        h_aux = evalin('base','findall(groot,''-regexp'',''Name'',''ZEFFIRO Interface:*'')');
    elseif isequal(arrange_target,'figs')
        h_aux = evalin('base','findall(groot,''-regexp'',''Name'',''ZEFFIRO Interface: Figure tool*'')');
    elseif isequal(arrange_target,'tools')
        h_aux = evalin('base','findall(groot,''Name'',''ZEFFIRO Interface:*'',''-not'',''-regexp'',''Name'',''ZEFFIRO Interface: Figure tool*'')');
    end
end

if isequal(arrange_mode,'tile')
    % Core checks arrange_function=='tile'. Here arrange_mode must be 'tile',
    % which means the handle-collecting branches above did not run.

    tile_mat = [1 : n_tiles];
    tile_mat = tile_mat'*tile_mat;
    screen_size = get(0, 'ScreenSize');
    thresh_val_1 = ceil(screen_size(4)/screen_size(3));
    thresh_val_2 = ceil(screen_size(3)/screen_size(4));
    for i = 1 : n_tiles
        tile_mat(i,thresh_val_1*i+1:end) = Inf;
        tile_mat(thresh_val_2*i+1:end,i) = Inf;
    end

    tile_mat(find(tile_mat < length(h_aux))) = Inf;
    [~, tile_mat_ind] = min(abs(tile_mat(:)-length(h_aux)));
    [n_1,n_2] = ind2sub(size(tile_mat),tile_mat_ind);
    [position_grid_1, position_grid_2] = meshgrid(linspace(0,1-1/n_1,n_1),linspace(0,1-1/n_2,n_2));
    for i = 1 : length(h_aux)
        unit_mode = get(h_aux(i),'units');
        if isequal(arrange_mode,'all')
            set(h_aux(i),'WindowState','normal');
        end
        if isequal(unit_mode,'pixels')
            set(h_aux(i),'position',round([position_grid_1(i)*screen_size(3) position_grid_2(i)*screen_size(4) screen_size(3)/n_1 screen_size(4)/n_2]))
        else
            set(h_aux(i),'position',[position_grid_1(i) position_grid_2(i) 1/n_1 1/n_2])
        end
    end
end

if isequal(arrange_mode,'maximize')
    for i = 1 : length(h_aux)
        set(h_aux(i),'WindowState','normal');
    end
end

if isequal(arrange_mode,'minimize')
    for i = 1 : length(h_aux)
        set(h_aux(i),'WindowState','minimized');
    end
end

end
