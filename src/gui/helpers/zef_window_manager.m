function varargout = zef_window_manager(action, varargin)
%ZEF_WINDOW_MANAGER  MATLAB R2025a+ window docking and lifecycle adapter.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Starting in R2025a, figure() defaults to WindowStyle='docked' (tabbed
%   figure container). Setting WindowStyle to 'docked' after Position /
%   OuterPosition re-docks the figure into the desktop/container, which
%   makes Zeffiro tool and figure windows appear to vanish. This helper
%   restores the pre-R2025a standalone-window behaviour Zeffiro's layout
%   and menu-bar stacking depend on, without changing groot defaults
%   permanently.
%
%   zef_window_manager('init')
%   zef_window_manager('restore')
%   h = zef_window_manager('standalone', h)
%   h = zef_window_manager('standalone', h, position)
%   zef_window_manager('raise', h)
%   zef_window_manager('sizechanged', h)
%   zef_window_manager('on_size_changed', src)
%   zef_window_manager('dock_menu', zef)
%   tf = zef_window_manager('is_protected', h)
%
%   See also figure, uifigure, matlab.ui.Figure/WindowStyle.

persistent original_defaults initialized

if nargin < 1 || isempty(action)
    action = 'init';
end
action = lower(char(string(action)));

switch action
    case 'init'
        if isempty(initialized) || ~initialized
            original_defaults = struct();
            original_defaults.WindowStyle = get(groot, 'defaultFigureWindowStyle');
            initialized = true;
        end
        % Factory default became 'docked' in R2025a. Zeffiro app windows
        % must remain standalone; plugin figure() calls read this default.
        set(groot, 'defaultFigureWindowStyle', 'normal');

    case 'restore'
        if ~isempty(original_defaults) && isfield(original_defaults, 'WindowStyle')
            try
                set(groot, 'defaultFigureWindowStyle', original_defaults.WindowStyle);
            catch
            end
        end
        initialized = false;
        original_defaults = [];

    case 'standalone'
        h = varargin{1};
        position = [];
        if numel(varargin) >= 2
            position = varargin{2};
        end
        h = local_make_standalone(h, position);
        if nargout > 0
            varargout{1} = h;
        end

    case 'raise'
        local_raise(varargin{1});

    case 'sizechanged'
        local_invoke_size_changed(varargin{1});

    case 'on_size_changed'
        local_on_size_changed(varargin{1});

    case 'dock_menu'
        local_dock_menu(varargin{1});

    case 'is_protected'
        reason = '';
        if numel(varargin) >= 2
            reason = varargin{2};
        end
        varargout{1} = local_is_protected(varargin{1}, reason);

    otherwise
        error('zef_window_manager:UnknownAction', 'Unknown action: %s', action);
end

end

function h = local_make_standalone(h, position)

if isempty(h) || ~isscalar(h) || ~isgraphics(h) || ~isvalid(h)
    return
end

% MATLAB docs (R2025a): set WindowStyle before Position / Resize.
try
    if isprop(h, 'WindowStyle') && ~strcmpi(char(h.WindowStyle), 'normal')
        h.WindowStyle = 'normal';
    end
catch
end

try
    if isprop(h, 'WindowState') && strcmpi(char(h.WindowState), 'minimized')
        % leave minimized unless we are applying a new position
        if ~isempty(position)
            h.WindowState = 'normal';
        end
    end
catch
end

if ~isempty(position)
    try
        h.Position = position;
    catch
    end
end

end

function local_raise(h)

if isempty(h) || ~isscalar(h) || ~isgraphics(h) || ~isvalid(h)
    return
end

local_make_standalone(h, []);

try
    if isprop(h, 'WindowState') && strcmpi(char(h.WindowState), 'minimized')
        h.WindowState = 'normal';
    end
catch
end

try
    h.Visible = 'on';
catch
end

try
    figure(h);
catch
end

end

function local_invoke_size_changed(h)

if isempty(h) || ~isscalar(h) || ~isgraphics(h) || ~isvalid(h)
    return
end

fcn = [];
try
    fcn = get(h, 'SizeChangedFcn');
catch
    return
end

if isempty(fcn)
    return
end

try
    if isa(fcn, 'function_handle')
        fcn(h, []);
    elseif iscell(fcn) && ~isempty(fcn) && isa(fcn{1}, 'function_handle')
        fcn{1}(h, [], fcn{2:end});
    else
        fcn_text = strtrim(char(string(fcn)));
        if isempty(fcn_text)
            return
        end
        evalin('base', fcn_text);
    end
catch
end

end

function local_on_size_changed(src)

if isempty(src) || ~isgraphics(src) || ~isvalid(src)
    return
end

ud = get(src, 'UserData');
if ~isstruct(ud) || ~isfield(ud, 'CurrentSize')
    return
end

exclude_cell = {};
if isfield(ud, 'ExcludeCell')
    exclude_cell = ud.ExcludeCell;
end
scale_positions = 1;
if isfield(ud, 'ScalePositions')
    scale_positions = ud.ScalePositions;
end

relative_size = [];
if isfield(ud, 'RelativeSize')
    relative_size = ud.RelativeSize;
end

ud.CurrentSize = zef_change_size_function(src, ud.CurrentSize, relative_size, exclude_cell, scale_positions);
set(src, 'UserData', ud);

end

function local_dock_menu(zef)

if ~isstruct(zef)
    return
end
if ~isfield(zef, 'h_zeffiro_menu') || ~isfield(zef, 'h_zeffiro_window_main')
    return
end
h_menu = zef.h_zeffiro_menu;
h_main = zef.h_zeffiro_window_main;
if isempty(h_menu) || isempty(h_main) || ~isvalid(h_menu) || ~isvalid(h_main)
    return
end

local_make_standalone(h_menu, []);
local_make_standalone(h_main, []);

try
    if isprop(h_menu, 'Scrollable')
        h_menu.Scrollable = 'off';
    end
catch
end

min_h = 0;
has_min = isprop(h_menu, 'ZefMenuMinHeight') && ~isempty(h_menu.ZefMenuMinHeight);
if has_min
    min_h = h_menu.ZefMenuMinHeight;
    is_expanded = h_menu.Position(4) > min_h + 1;
else
    min_h = local_menu_min_height(h_menu);
    is_expanded = false;
end

expanded_size = min_h;
if isfield(zef, 'menu_expanded_size') && ~isempty(zef.menu_expanded_size)
    expanded_size = zef.menu_expanded_size;
end
main_pos = h_main.Position;

sc = [];
try
    sc = h_menu.SizeChangedFcn;
    h_menu.SizeChangedFcn = '';
catch
end

if is_expanded
    h_menu.Position = [main_pos(1), main_pos(2) + main_pos(4) - expanded_size, main_pos(3), expanded_size];
else
    h_menu.Position = [main_pos(1), main_pos(2) + main_pos(4), main_pos(3), min_h];
end

try
    h_menu.SizeChangedFcn = sc;
catch
end

end

function min_h = local_menu_min_height(h_menu)

min_h = 0;
if isprop(h_menu, 'ZefMenuMinHeight') && ~isempty(h_menu.ZefMenuMinHeight)
    min_h = h_menu.ZefMenuMinHeight;
    return
end

sc = [];
orig = h_menu.Position;
try
    sc = h_menu.SizeChangedFcn;
    h_menu.SizeChangedFcn = '';
catch
end

try
    h_menu.Position(4) = 0;
    drawnow;
    min_h = h_menu.Position(4);
    h_menu.Position = orig;
catch
    min_h = 0;
end

try
    h_menu.SizeChangedFcn = sc;
catch
end

try
    if ~isprop(h_menu, 'ZefMenuMinHeight')
        addprop(h_menu, 'ZefMenuMinHeight');
    end
    h_menu.ZefMenuMinHeight = min_h;
catch
end

end

function tf = local_is_protected(h, reason)

tf = false;
if isempty(h) || ~isscalar(h) || ~isgraphics(h) || ~isvalid(h)
    return
end

name = '';
try
    name = char(get(h, 'Name'));
catch
end

is_menu = contains(name, 'ZEFFIRO Interface: Menu tool');
is_task = contains(name, 'ZEFFIRO Interface: Task ');
try
    is_task = is_task || isprop(h, 'ZefWaitbarStartTime') ...
        || strcmp(char(string(get(h, 'Tag'))), 'progress_bar');
catch
end
is_seg = contains(name, 'ZEFFIRO Interface: Segmentation tool');

% Menu bar and waitbars are never tiled/closed/minimized: closing the menu
% runs zef_close_all; tiling it breaks the stacked-menu layout.
if is_menu || is_task
    tf = true;
    return
end

if is_seg && ismember(lower(char(string(reason))), {'close', 'minimize'})
    tf = true;
end

end
