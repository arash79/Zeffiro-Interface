function zef_ui_interact(varargin)
%ZEF_UI_INTERACT  Pointer, hover, and press feedback for traditional chrome.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Traditional uicontrols do not expose mouse-enter events. This helper
%   binds cheap figure-level motion/press/release listeners so buttons,
%   nav, flyouts, and toolbar chrome show a hand pointer and, where a
%   rounded CData button is present, a hover/press fill. Idle pixels are
%   unchanged. uifigure widgets keep native hover; they only get pointer
%   feedback.
%
%   zef_ui_interact(fig)
%   zef_ui_interact(fig, 'bind')
%   zef_ui_interact(fig, 'motion')
%   zef_ui_interact(fig, 'press')
%   zef_ui_interact(fig, 'release')
%   zef_ui_interact(fig, 'sync')
%   zef_ui_interact(h, 'paint', state)
%
%   See also zef_ui_round_button, zef_ui_ready, zef_ui_shell.

if nargin < 1 || isempty(varargin{1})
    return
end
target = varargin{1};
action = 'bind';
if nargin >= 2 && (ischar(varargin{2}) || isstring(varargin{2}))
    action = lower(char(varargin{2}));
end

switch action
    case 'bind'
        local_bind(target);
    case 'motion'
        if nargin >= 3 && local_ok(varargin{3})
            local_motion(target, varargin{3});
        else
            local_motion(target);
        end
    case 'press'
        local_press(target);
    case 'release'
        local_release(target);
    case 'sync'
        local_sync(target);
    case 'paint'
        state = 'idle';
        if nargin >= 3
            state = char(varargin{3});
        end
        local_paint(target, state);
    otherwise
        local_bind(target);
end

end

function local_bind(fig)

fig = local_fig_of(fig);
if isempty(fig)
    return
end
try
    if isappdata(fig, 'ZefInteractBound') && isequal(getappdata(fig, 'ZefInteractBound'), true)
        return
    end
catch
end
try
    tag = char(fig.Tag);
    name = char(fig.Name);
    if strcmp(tag, 'progress_bar') || contains(name, 'Menu tool')
        return
    end
catch
end
try
    if matlab.ui.internal.isUIFigure(fig)
        try
            need_ptr = true;
            if isappdata(fig, 'ZefUiPointerBound')
                lh0 = getappdata(fig, 'ZefUiPointerBound');
                need_ptr = isempty(lh0) || ~isvalid(lh0);
            end
            if need_ptr
                lh = addlistener(fig, 'WindowMouseMotion', @(s, ~) zef_ui_interact(s, 'motion'));
                setappdata(fig, 'ZefUiPointerBound', lh);
            end
        catch
        end
        setappdata(fig, 'ZefInteractBound', true);
        return
    end
catch
end

has_shell_motion = false;
try
    has_shell_motion = isappdata(fig, 'ZefNavHoverListener');
    if has_shell_motion
        lh = getappdata(fig, 'ZefNavHoverListener');
        has_shell_motion = ~isempty(lh) && isvalid(lh);
    end
catch
end
if ~has_shell_motion
    try
        lh = addlistener(fig, 'WindowMouseMotion', @(s, ~) zef_ui_interact(s, 'motion'));
        setappdata(fig, 'ZefInteractMotion', lh);
    catch
        try
            if ~isappdata(fig, 'ZefInteractPrevMotion')
                prev = get(fig, 'WindowButtonMotionFcn');
                setappdata(fig, 'ZefInteractPrevMotion', prev);
                fig.WindowButtonMotionFcn = @(s, e) local_motion_wrap(s, e);
            end
        catch
        end
    end
end
try
    lh = addlistener(fig, 'WindowMousePress', @(s, ~) zef_ui_interact(s, 'press'));
    setappdata(fig, 'ZefInteractPress', lh);
catch
end
try
    lh = addlistener(fig, 'WindowMouseRelease', @(s, ~) zef_ui_interact(s, 'release'));
    setappdata(fig, 'ZefInteractRelease', lh);
catch
end
try
    setappdata(fig, 'ZefInteractBound', true);
catch
end

end

function local_motion_wrap(src, evt)

zef_ui_interact(src, 'motion');
prev = [];
try
    prev = getappdata(src, 'ZefInteractPrevMotion');
catch
end
try
    if isa(prev, 'function_handle')
        prev(src, evt);
    elseif (ischar(prev) || isstring(prev)) && strlength(prev) > 0
        evalin('base', char(prev));
    end
catch
end

end

function local_motion(fig, hit)

fig = local_fig_of(fig);
if isempty(fig)
    return
end
obj = [];
if nargin >= 2 && local_ok(hit)
    obj = hit;
else
    try
        obj = hittest(fig);
    catch
    end
end
btn = local_round_of(obj);
prev = [];
try
    prev = getappdata(fig, 'ZefHoverHandle');
catch
end
if ~isequal(prev, btn)
    if local_ok(prev)
        local_paint(prev, 'idle');
    end
    if local_ok(btn)
        local_paint(btn, 'hover');
    end
    try
        setappdata(fig, 'ZefHoverHandle', btn);
    catch
    end
end
fly = local_flyout_item(obj);
prev_fly = [];
try
    prev_fly = getappdata(fig, 'ZefFlyoutHover');
catch
end
if ~isequal(prev_fly, fly)
    if local_ok(prev_fly) && ~local_is_open_fly_item(fig, prev_fly)
        local_flyout_paint(prev_fly, false);
    end
    if local_ok(fly)
        local_flyout_paint(fly, true);
    end
    try
        setappdata(fig, 'ZefFlyoutHover', fly);
    catch
    end
end
local_pointer(fig, obj, btn, fly);

end

function local_press(fig)

fig = local_fig_of(fig);
if isempty(fig)
    return
end
obj = [];
try
    obj = hittest(fig);
catch
end
btn = local_round_of(obj);
if local_ok(btn)
    local_paint(btn, 'press');
    try
        setappdata(fig, 'ZefPressHandle', btn);
    catch
    end
end

end

function local_release(fig)

fig = local_fig_of(fig);
if isempty(fig)
    return
end
btn = [];
try
    btn = getappdata(fig, 'ZefPressHandle');
catch
end
try
    setappdata(fig, 'ZefPressHandle', []);
catch
end
if ~local_ok(btn)
    return
end
obj = [];
try
    obj = hittest(fig);
catch
end
over = local_round_of(obj);
if isequal(over, btn)
    local_paint(btn, 'hover');
else
    local_paint(btn, 'idle');
end

end

function local_sync(fig)

fig = local_fig_of(fig);
if isempty(fig)
    return
end
try
    zef_ui_polish_window(fig);
catch
end
try
    setappdata(fig, 'ZefHoverHandle', []);
    setappdata(fig, 'ZefPressHandle', []);
    setappdata(fig, 'ZefFlyoutHover', []);
catch
end

end

function local_pointer(fig, obj, btn, fly)

if ~local_ok(fig)
    return
end
cur = 'arrow';
try
    cur = char(fig.Pointer);
catch
end
if ~isempty(cur) && ~strcmpi(cur, 'arrow') && ~strcmpi(cur, 'hand') ...
        && ~strcmpi(cur, 'ibeam')
    return
end
want = 'arrow';
if local_is_edit(obj)
    want = 'ibeam';
elseif local_ok(btn) || local_ok(fly) || local_is_clickable(obj)
    want = 'hand';
end
if ~strcmpi(cur, want)
    try
        fig.Pointer = want;
    catch
    end
end

end

function tf = local_is_clickable(obj)

tf = false;
if ~local_ok(obj)
    return
end
tag = '';
try
    tag = char(obj.Tag);
catch
end
if strncmp(tag, 'zef_card_', 9) || strcmp(tag, 'zef_header_rule') ...
        || strcmp(tag, 'zef_nav_sep') || strcmp(tag, 'zef_tool_sep') ...
        || strcmp(tag, 'zef_tool_rule') || strcmp(tag, 'zef_tab_underline') ...
        || strcmp(tag, 'zef_tab_rule') || strncmp(tag, 'status_', 7)
    return
end
try
    if isprop(obj, 'Enable') && strcmpi(char(obj.Enable), 'off')
        return
    end
catch
end
if strncmp(tag, 'zef_nav_', 8) || strncmp(tag, 'zef_tool_', 9) ...
        || strncmp(tag, 'zef_tab_', 8) || contains(tag, 'zef_shell_flyout') ...
        || strcmp(tag, 'zef_shell_theme_pill') || strcmp(tag, 'zef_shell_theme_label') ...
        || strcmp(tag, 'zef_shell_theme_sun') || strcmp(tag, 'zef_shell_help') ...
        || strcmp(tag, 'zef_shell_bell') || strcmp(tag, 'zef_shell_profile')
    try
        if strcmpi(char(obj.Enable), 'off')
            return
        end
    catch
    end
    tf = true;
    return
end
try
    typ = lower(char(obj.Type));
catch
    typ = '';
end
if strcmp(typ, 'uicontrol')
    try
        en = lower(char(obj.Enable));
        if strcmp(en, 'off')
            return
        end
        if strcmp(en, 'inactive')
            tf = ~isempty(obj.ButtonDownFcn);
            try
                ud = obj.UserData;
                if local_ok(ud) && strcmpi(char(ud.Enable), 'off')
                    tf = false;
                end
            catch
            end
            return
        end
    catch
    end
    style = '';
    try
        style = lower(char(obj.Style));
    catch
    end
    if any(strcmp(style, {'checkbox', 'radiobutton', 'slider', 'listbox', 'popupmenu'}))
        tf = true;
        return
    end
    if any(strcmp(style, {'pushbutton', 'togglebutton', 'text'}))
        try
            tf = ~isempty(obj.Callback) || ~isempty(obj.ButtonDownFcn);
        catch
        end
        return
    end
end
cls = class(obj);
if contains(cls, 'Button') || contains(cls, 'CheckBox') ...
        || contains(cls, 'DropDown') || contains(cls, 'ListBox') ...
        || contains(cls, 'Slider') && ~strcmp(typ, 'axes')
    tf = true;
end

end

function tf = local_is_edit(obj)

tf = false;
if ~local_ok(obj)
    return
end
try
    if strcmpi(char(obj.Type), 'uicontrol') && strcmpi(char(obj.Style), 'edit')
        tf = true;
        return
    end
catch
end
cls = class(obj);
tf = contains(cls, 'EditField') || contains(cls, 'TextArea') ...
    || contains(cls, 'Spinner');

end

function btn = local_round_of(obj)

btn = [];
h = obj;
for i = 1:6
    if ~local_ok(h)
        return
    end
    try
        if isappdata(h, 'ZefRoundKey')
            try
                if strcmpi(char(h.Enable), 'off')
                    btn = [];
                    return
                end
            catch
            end
            btn = h;
            return
        end
    catch
    end
    try
        ud = h.UserData;
        if local_ok(ud) && isappdata(ud, 'ZefRoundKey')
            btn = ud;
            return
        end
    catch
    end
    tag = '';
    try
        tag = char(h.Tag);
    catch
    end
    if length(tag) > 4 && strcmp(tag(end-3:end), '_cap')
        try
            if local_ok(h.UserData)
                btn = h.UserData;
                return
            end
        catch
        end
    end
    try
        h = h.Parent;
    catch
        return
    end
end

end

function tf = local_is_open_fly_item(fig, item)

tf = false;
open = {};
try
    open = getappdata(fig, 'ZefFlyoutOpenItems');
catch
end
if ~iscell(open)
    return
end
for i = 1:numel(open)
    if isequal(open{i}, item)
        tf = true;
        return
    end
end

end

function item = local_flyout_item(obj)

item = [];
h = obj;
for i = 1:8
    if ~local_ok(h)
        return
    end
    tag = '';
    try
        tag = char(h.Tag);
    catch
    end
    if contains(tag, 'zef_shell_flyout') && ~strcmpi(char(h.Type), 'uicontrol')
        return
    end
    try
        if strcmpi(char(h.Type), 'uicontrol')
            par = h.Parent;
            ptag = '';
            try
                ptag = char(par.Tag);
            catch
            end
            if contains(ptag, 'zef_shell_flyout')
                style = lower(char(h.Style));
                if any(strcmp(style, {'text', 'pushbutton'}))
                    item = h;
                    return
                end
            end
        end
    catch
    end
    try
        h = h.Parent;
    catch
        return
    end
end

end

function local_flyout_paint(item, is_hover)

if ~local_ok(item)
    return
end
theme = [];
try
    theme = zef_ui_theme();
catch
    return
end
fillc = theme.color.panel;
try
    if is_hover
        fillc = theme.color.hover;
    end
catch
end
try
    item.BackgroundColor = fillc;
catch
end

end

function local_paint(btn, state)

if ~local_ok(btn)
    return
end
if nargin < 2 || isempty(state)
    state = 'idle';
end
state = lower(char(state));
idle = [];
try
    idle = getappdata(btn, 'ZefRoundIdle');
catch
end
if isempty(idle)
    try
        idle = btn.CData;
        setappdata(btn, 'ZefRoundIdle', idle);
    catch
        return
    end
end
fill_idle = [];
try
    fill_idle = getappdata(btn, 'ZefRoundFill');
catch
end
cdata = idle;
fillc = fill_idle;
if ~strcmp(state, 'idle')
    [cdata, fillc] = local_state_cdata(btn, state, idle, fill_idle);
end
try
    btn.CData = cdata;
catch
end
cap = local_caption(btn);
if local_ok(cap) && ~isempty(fillc)
    try
        cap.BackgroundColor = fillc;
    catch
    end
end
try
    setappdata(btn, 'ZefRoundState', state);
catch
end

end

function [cdata, fillc] = local_state_cdata(btn, state, idle, fill_idle)

cdata = idle;
fillc = fill_idle;
cache_name = 'ZefRoundHover';
if strcmp(state, 'press')
    cache_name = 'ZefRoundPress';
end
try
    cached = getappdata(btn, cache_name);
    cached_fill = getappdata(btn, [cache_name 'Fill']);
    if ~isempty(cached)
        cdata = cached;
        if ~isempty(cached_fill)
            fillc = cached_fill;
        end
        return
    end
catch
end
theme = [];
try
    theme = zef_ui_theme();
catch
    return
end
if isempty(fill_idle)
    try
        fill_idle = theme.color.button;
    catch
        return
    end
end
hover_tok = fill_idle;
try
    hover_tok = theme.color.hover;
catch
end
is_primary = false;
try
    is_primary = isequal(getappdata(btn, 'ZefRoundPrimary'), true);
catch
end
if is_primary
    try
        hover_tok = theme.color.accentHover;
    catch
    end
    fillc = 0.78 * fill_idle + 0.22 * hover_tok;
else
    fillc = 0.62 * fill_idle + 0.38 * hover_tok;
end
if strcmp(state, 'press')
    try
        press_tok = theme.color.accentPressed;
        fillc = 0.82 * fillc + 0.18 * press_tok;
    catch
        fillc = 0.88 * fillc;
    end
end
fillc = max(0, min(1, fillc));
try
    w = size(idle, 2);
    ht = size(idle, 1);
    r = 6;
    try
        r = getappdata(btn, 'ZefRoundRadius');
        if isempty(r)
            r = 6;
        end
    catch
    end
    outer = theme.color.panel;
    try
        stored = getappdata(btn, 'ZefRoundOuter');
        if ~isempty(stored)
            outer = stored;
        end
    catch
    end
    borderc = theme.color.border;
    cdata = zef_ui_roundrect(w, ht, min(r, floor(min(w, ht) / 2) - 1), ...
        fillc, borderc, outer);
    setappdata(btn, cache_name, cdata);
    setappdata(btn, [cache_name 'Fill'], fillc);
catch
end

end

function cap = local_caption(btn)

cap = [];
try
    tag = [char(btn.Tag) '_cap'];
    found = findall(btn.Parent, 'Tag', tag, 'Type', 'uicontrol');
    if ~isempty(found)
        cap = found(1);
    end
catch
end

end

function fig = local_fig_of(h)

fig = [];
if ~local_ok(h)
    return
end
try
    if strcmpi(char(h.Type), 'figure')
        fig = h;
        return
    end
catch
end
try
    fig = ancestor(h, 'figure');
catch
end
if ~local_ok(fig)
    fig = [];
end

end

function tf = local_ok(h)

tf = false;
try
    tf = ~isempty(h) && isgraphics(h) && isvalid(h);
catch
end

end
