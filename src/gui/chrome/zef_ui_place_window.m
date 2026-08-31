function zef_ui_place_window(h)
%ZEF_UI_PLACE_WINDOW  Center and clamp a window to the usable screen.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Placement runs once, at creation. After ZefPlaced is set, this
%   function is a no-op: it must not clamp, centre, or write Position
%   again. Doing so from zef_ui_ready, resize, or a second open fights
%   the user and retriggers layout.
%
%   zef_ui_place_window(h)
%
%   See also zef_ui_clamp_position, zef_ui_center_position, zef_ui_ready.

if nargin < 1 || isempty(h) || ~isgraphics(h) || ~isvalid(h)
    return
end
try
    if isappdata(h, 'ZefPlaced') && isequal(getappdata(h, 'ZefPlaced'), true)
        return
    end
catch
end

tag = '';
name = '';
try
    tag = char(h.Tag);
catch
end
try
    name = char(h.Name);
catch
end
if strcmp(tag, 'progress_bar')
    return
end

pos = local_read_pos(h);
if isempty(pos)
    return
end

is_main = strcmp(tag, 'figure_tool') || contains(name, 'Figure tool');
is_menu = contains(name, 'Menu tool');
anchor = [];
if ~is_main && ~is_menu
    anchor = local_session_anchor(h);
end

if is_main || is_menu
    work = zef_ui_screen_workarea(pos);
    pos = zef_ui_center_position(pos, work);
    pos = zef_ui_clamp_position(pos, work);
elseif local_is_default_origin(pos) && ~isempty(anchor)
    try
        au = anchor.Units;
        anchor.Units = 'pixels';
        ap = double(anchor.Position);
        anchor.Units = au;
        pos = zef_ui_center_position(pos, ap);
    catch
    end
    pos = zef_ui_clamp_position(pos, zef_ui_screen_workarea(anchor));
else
    pos = zef_ui_clamp_position(pos, zef_ui_screen_workarea(pos));
end

pos = local_unstack(h, pos);
pos = zef_ui_clamp_position(pos, zef_ui_screen_workarea(pos));

local_write_pos(h, pos);
try
    setappdata(h, 'ZefPlaced', true);
catch
end

end

function pos = local_read_pos(h)

pos = [];
try
    orig_u = h.Units;
    h.Units = 'pixels';
    pos = double(h.Position);
    h.Units = orig_u;
catch
    pos = [];
end
if numel(pos) < 4 || any(~isfinite(pos))
    pos = [];
end

end

function local_write_pos(h, pos)

try
    orig_u = h.Units;
    h.Units = 'pixels';
    cur = double(h.Position);
    if numel(cur) >= 4 && max(abs(cur(:) - pos(:))) < 0.51
        h.Units = orig_u;
        return
    end
    h.Position = pos;
    h.Units = orig_u;
catch
end

end

function tf = local_is_default_origin(pos)

tf = false;
if numel(pos) < 2
    return
end
defaults = [100 100; 120 120; 160 160; 0 0; 1 1; 80 80];
for i = 1:size(defaults, 1)
    if abs(pos(1) - defaults(i, 1)) < 12 && abs(pos(2) - defaults(i, 2)) < 12
        tf = true;
        return
    end
end

end

function anchor = local_session_anchor(skip)

anchor = [];
figs = [];
try
    figs = findall(groot, 'Type', 'figure');
catch
    return
end
best_area = 0;
for i = 1:numel(figs)
    f = figs(i);
    if isempty(f) || ~isvalid(f) || isequal(f, skip)
        continue
    end
    ftag = '';
    fname = '';
    try
        ftag = char(f.Tag);
    catch
    end
    try
        fname = char(f.Name);
    catch
    end
    if strcmp(ftag, 'progress_bar') || contains(fname, 'Menu tool')
        continue
    end
    is_main = strcmp(ftag, 'figure_tool') || contains(fname, 'Figure tool');
    is_zef = is_main || contains(fname, 'ZEFFIRO Interface') ...
        || contains(lower(fname), 'zeffiro');
    if ~is_zef
        continue
    end
    vis = true;
    try
        vis = strcmpi(char(f.Visible), 'on');
    catch
    end
    if ~vis && ~is_main
        continue
    end
    if is_main
        anchor = f;
        return
    end
    try
        u = f.Units;
        f.Units = 'pixels';
        p = f.Position;
        f.Units = u;
        area = p(3) * p(4);
        if area > best_area
            best_area = area;
            anchor = f;
        end
    catch
    end
end

end

function pos = local_unstack(h, pos)

figs = [];
try
    figs = findall(groot, 'Type', 'figure');
catch
    return
end
for step = 1:8
    stacked = false;
    for i = 1:numel(figs)
        f = figs(i);
        if isempty(f) || ~isvalid(f) || isequal(f, h)
            continue
        end
        try
            fname = char(f.Name);
            ftag = char(f.Tag);
        catch
            continue
        end
        if strcmp(ftag, 'progress_bar') || contains(fname, 'Menu tool')
            continue
        end
        try
            u = f.Units;
            f.Units = 'pixels';
            op = f.Position;
            f.Units = u;
        catch
            continue
        end
        if abs(op(1) - pos(1)) < 16 && abs(op(2) - pos(2)) < 16
            stacked = true;
            break
        end
    end
    if ~stacked
        return
    end
    pos(1) = pos(1) + 28;
    pos(2) = pos(2) - 28;
end

end
