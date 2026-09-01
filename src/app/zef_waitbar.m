function h_waitbar = zef_waitbar(varargin)
%ZEF_WAITBAR  Create or update the Zeffiro progress window.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Progress UI for mesh, lead-field, and inverse work. The public calling
%   conventions match the historical zef_waitbar API used throughout the
%   project. The window is a compact standalone uifigure with labels and a
%   filled progress bar (not MATLAB waitbar, not linear uigauge). That
%   avoids the pre-R2025a figure/uicontrol/axes/barh mix, which is unstable
%   on MATLAB's WebGL graphics stack, and also avoids the analog-gauge
%   ruler that App Designer uses for uigauge('linear').
%
%   h = zef_waitbar(current_iter, max_iter, message)
%   h = zef_waitbar(current_iter, max_iter, h_waitbar)
%   h = zef_waitbar(current_iter, max_iter, h_waitbar, message)
%   h = zef_waitbar(ratio, h_waitbar)
%   h = zef_waitbar(ratio, h_waitbar, message)
%   h = zef_waitbar(ratio, message)
%   zef_waitbar('theme')
%
%   close(h) destroys the window when this caller owns it. A new initialize
%   call reuses the existing singleton figure so nested processes keep a
%   valid handle. Nested initialize from a different function increments a
%   nest count; close() from that nested caller only decrements, so the
%   parent handle stays valid. MATLAB's close() is skipped when identifying
%   the closer so nest counting sees the real caller. delete(h) and
%   zef_delete_waitbar still force-destroy. Updating a deleted handle
%   recreates it. Redraws smaller than about 1% are skipped except at 0%,
%   100%, or when the message changes.
%
%   See also zef_waitbar, zef_close_waitbar, uifigure, zef_window_manager.

if nargin == 1 && (ischar(varargin{1}) || isstring(varargin{1})) ...
        && strcmpi(strtrim(char(varargin{1})), 'theme')
    local_theme_open();
    h_waitbar = [];
    return
end

if nargin < 2 || nargin > 4
    error('zef_waitbar:InvalidNargin', 'zef_waitbar needs 2, 3, or 4 arguments.');
end

[action, ratio, h_in, msg, current_iter] = local_parse(varargin{:});

if ~strcmp(action, 'init') && local_is_valid(h_in)
    if local_should_skip(h_in, ratio, msg)
        h_waitbar = h_in;
        return
    end
    local_set_progress_prop(h_in, current_iter);
end

menu = local_find_menu();
opts = local_menu_options(menu);
[opts.caller, opts.owner] = local_caller_identity();

if strcmp(action, 'init') || ~local_is_valid(h_in)
    h_waitbar = local_create(opts, msg, menu);
    local_set_progress_prop(h_waitbar, current_iter);
    local_paint(h_waitbar, ratio, msg, opts, true);
else
    h_waitbar = h_in;
    local_paint(h_waitbar, ratio, msg, opts, false);
end

end

%% Argument parsing

function [action, ratio, h, msg, current_iter] = local_parse(varargin)

h = [];
msg = '';
nums = {};

for k = 1:nargin
    a = varargin{k};
    if local_looks_like_handle(a)
        h = a;
    elseif ischar(a) || isstring(a)
        msg = char(string(a));
    elseif isnumeric(a)
        nums{end+1} = double(a); %#ok<AGROW>
    else
        error('zef_waitbar:InvalidArgument', ...
            'Argument %d must be numeric, text, or a graphics handle.', k);
    end
end

if isempty(nums)
    error('zef_waitbar:MissingProgress', 'zef_waitbar needs a numeric progress value.');
end

if numel(nums) >= 2
    % Nested waitbars pass vectors (e.g. [i j n_rep f_ind] vs max of each
    % loop). Ratio is elementwise current./max, then clamped to [0,1];
    % the gauge uses max(ratio(:)).
    current_iter = nums{1};
    max_iter = nums{2};
    if isempty(max_iter) || ~all(isfinite(max_iter(:))) || max(abs(max_iter(:))) == 0
        ratio = 0;
    else
        ratio = current_iter ./ max_iter;
    end
else
    current_iter = nums{1};
    ratio = current_iter;
end

if isempty(ratio)
    ratio = 0;
else
    ratio = max(0, min(1, max(ratio(:))));
end

if isempty(current_iter)
    current_iter = 0;
else
    current_iter = current_iter(1);
end

if ~local_is_valid(h)
    action = 'init';
elseif strlength(string(msg)) > 0
    action = 'progress_text';
else
    action = 'progress';
end

end

function tf = local_looks_like_handle(h)
% Numeric 0 is groot (isgraphics(0) is true). Never treat doubles as waitbar handles.
tf = ~isempty(h) && isscalar(h) && ~isnumeric(h) ...
    && (isgraphics(h) || isa(h, 'matlab.ui.Figure'));
if tf
    try
        tf = ~isequal(h, groot);
    catch
    end
end
end

function tf = local_is_valid(h)
tf = local_looks_like_handle(h);
if tf
    try
        tf = isvalid(h);
    catch
        tf = false;
    end
end
end

function tf = local_should_skip(h, ratio, msg)
% Never skip a reset (0) or completion (1). Never skip a changed message.
% Skip redraws smaller than 1% in ratio space.
if ratio <= 0 || ratio >= 1
    tf = false;
    return
end
if strlength(string(msg)) > 0
    try
        ud = h.UserData;
        if isstruct(ud) && isfield(ud, 'msgLabel') && isvalid(ud.msgLabel)
            if ~strcmp(char(string(ud.msgLabel.Text)), char(string(msg)))
                tf = false;
                return
            end
        end
    catch
    end
end
tf = false;
try
    ud = h.UserData;
    if isstruct(ud) && isfield(ud, 'lastRatio')
        tf = abs(ratio - ud.lastRatio) < 0.01;
    end
catch
    tf = false;
end
end

function local_set_progress_prop(h, current_iter)
if ~local_is_valid(h)
    return
end
try
    if ~isprop(h, 'ZefWaitbarCurrentProgress')
        addprop(h, 'ZefWaitbarCurrentProgress');
    end
    h.ZefWaitbarCurrentProgress = current_iter;
catch
end
end

%% Menu / options

function menu = local_find_menu()
% Cache the menu figure. Callers such as mesh labeling update the waitbar
% tens of times per compartment; findall(groot) walks the whole graphics
% tree (CanvasContainerModel.doCollectChildren) and dominated create_fem_mesh
% in profiles. isvalid() misses a replaced menu, so refetch then.
persistent cached_menu
menu = [];
if ~isempty(cached_menu)
    try
        if isvalid(cached_menu)
            menu = cached_menu;
            return
        end
    catch
        cached_menu = [];
    end
end
try
    found = findall(groot, 'ZefTool', 'zef_menu_tool');
    if ~isempty(found)
        menu = found(1);
        if ~isvalid(menu)
            menu = [];
        end
    end
catch
    menu = [];
end
cached_menu = menu;
end

function opts = local_menu_options(menu)

opts = struct();
opts.visible = true;
opts.font_size = 12;
opts.verbose = false;
opts.use_log = false;
opts.log_file = '';
opts.task_id = 0;
opts.restart_time = now;
opts.position = [100 80 480 136];

if isempty(menu) || ~isvalid(menu)
    return
end

try
    if isprop(menu, 'ZefUseWaitbar') && ~menu.ZefUseWaitbar
        opts.visible = false;
    else
        % The menu-owner uifigure is hidden in the unified shell. Its
        % Visible flag must not hide waitbars; only ZefUseWaitbar does.
        opts.visible = true;
        always = false;
        if isprop(menu, 'ZefAlwaysShowWaitbar')
            always = logical(menu.ZefAlwaysShowWaitbar);
        end
        is_hidden_shell_menu = false;
        try
            is_hidden_shell_menu = isprop(menu, 'ZefTool') ...
                && strcmp(char(string(menu.ZefTool)), 'zef_menu_tool') ...
                && strcmpi(char(string(menu.Visible)), 'off');
        catch
        end
        if ~is_hidden_shell_menu && ~always
            menu_vis = true;
            if isprop(menu, 'Visible')
                menu_vis = strcmpi(char(string(menu.Visible)), 'on');
            end
            opts.visible = menu_vis || always;
        end
    end
catch
end

try
    if isprop(menu, 'ZefFontSize') && ~isempty(menu.ZefFontSize)
        opts.font_size = double(menu.ZefFontSize);
    end
catch
end

try
    if isprop(menu, 'ZefVerboseMode')
        opts.verbose = logical(menu.ZefVerboseMode);
    end
catch
end

try
    if isprop(menu, 'ZefUseLog')
        opts.use_log = logical(menu.ZefUseLog);
    end
    if isprop(menu, 'ZefCurrentLogFile')
        opts.log_file = char(string(menu.ZefCurrentLogFile));
    end
catch
end

try
    if isprop(menu, 'ZefTaskId')
        opts.task_id = double(menu.ZefTaskId);
    end
    if isprop(menu, 'ZefRestartTime')
        opts.restart_time = menu.ZefRestartTime;
    end
catch
end

try
    mp = menu.Position;
    if numel(mp) == 4
        width = min(520, max(440, mp(3)));
        height = 136;
        opts.position = [mp(1), max(30, mp(2) - height - 12), width, height];
    end
catch
end

% The menu owner is hidden in the unified shell. Center the waitbar on
% the visible Figure tool so progress is not off-screen or behind it.
try
    zef_live = evalin('base', 'zef');
    if isstruct(zef_live) && isfield(zef_live, 'h_zeffiro') ...
            && isvalid(zef_live.h_zeffiro) ...
            && strcmpi(char(string(zef_live.h_zeffiro.Visible)), 'on')
        fp = zef_live.h_zeffiro.Position;
        width = min(540, max(480, round(0.42 * fp(3))));
        height = 136;
        opts.position = [fp(1) + fp(3)/2 - width/2, ...
            max(40, fp(2) + fp(4)/2 - height/2), width, height];
    end
catch
end

end

function [file_name, owner] = local_caller_identity()
file_name = 'unknown';
owner = 'unknown';
try
    st = dbstack('-completenames');
    for i = 1:numel(st)
        if local_is_waitbar_frame(st(i))
            continue
        end
        [~, file_name, ext] = fileparts(st(i).file);
        file_name = [file_name ext]; %#ok<AGROW>
        owner = st(i).name;
        return
    end
catch
end
end

function tf = local_is_waitbar_frame(frame)
n = frame.name;
tf = strcmp(n, 'zef_waitbar') || startsWith(n, 'zef_waitbar/') ...
    || strcmp(n, 'zef_close_waitbar') || startsWith(n, 'zef_close_waitbar/') ...
    || contains(n, 'close_waitbar') ...
    || strcmp(n, 'close') || startsWith(n, 'close/') ...
    || strcmp(n, 'closereq') ...
    || startsWith(n, 'local_') || contains(n, 'onCleanup') ...
    || startsWith(n, '@');
end

%% Create / paint

function fig = local_create(opts, msg, menu)

existing = local_find_existing();
if local_is_valid(existing) && local_has_ui(existing)
    fig = local_reset(existing, opts, msg);
else
    if ~isempty(existing)
        zef_delete_waitbar;
    end
    fig = local_build(opts, msg);
end

try
    zef_window_manager('standalone', fig);
catch
end

if ~isempty(menu) && isvalid(menu)
    try
        if isprop(menu, 'ZefWaitbarHandle')
            menu.ZefWaitbarHandle = fig;
        end
        if isprop(menu, 'ZefTaskId')
            menu.ZefTaskId = menu.ZefTaskId + 1;
        end
    catch
    end
end

if opts.visible
    fig.Visible = 'on';
    try
        zef_window_manager('raise', fig);
    catch
        try
            figure(fig);
        catch
        end
    end
    drawnow;
else
    fig.Visible = 'off';
end

end

function fig = local_find_existing()
fig = [];
found = findall(groot, '-property', 'ZefWaitbarStartTime');
if isempty(found)
    found = findall(groot, 'Tag', 'progress_bar');
end
keep = false(size(found));
for i = 1:numel(found)
    keep(i) = isgraphics(found(i)) && isvalid(found(i));
end
found = found(keep);
if isempty(found)
    return
end
fig = found(1);
if numel(found) > 1
    extra = found(2:end);
    try
        set(extra, 'CloseRequestFcn', '');
        set(extra, 'DeleteFcn', '');
        delete(extra);
    catch
    end
end
end

function tf = local_has_ui(fig)
tf = false;
try
    ud = fig.UserData;
    tf = isstruct(ud) && isfield(ud, 'msgLabel') && local_is_valid(ud.msgLabel) ...
        && isfield(ud, 'pctLabel') && local_is_valid(ud.pctLabel);
    if tf
        has_html = isfield(ud, 'htmlBar') && local_is_valid(ud.htmlBar);
        has_native = isfield(ud, 'barGrid') && local_is_valid(ud.barGrid);
        tf = has_html || has_native;
    end
catch
    tf = false;
end
end

function fig = local_reset(fig, opts, msg)
local_bump_nest(fig, opts);
fig.Name = local_task_name(opts.task_id);
fig.Tag = 'progress_bar';
fig.CloseRequestFcn = @(src, ~) local_on_close(src);
fig.DeleteFcn = '';
fig.ZefWaitbarStartTime = now;
fig.ZefWaitbarCurrentProgress = 0;
local_set_value_prop(fig, 0);

ud = fig.UserData;
theme = local_theme();
ud.msgLabel.Text = local_default_msg(msg);
ud.fileLabel.Text = opts.caller;
ud.readyLabel.Text = '';
ud.pctLabel.Text = '0%';
local_set_bar(ud, 0, theme);
ud.startTime = now;
ud.lastDetailTime = 0;
ud.cpuMark = cputime;
ud.wallMark = now * 86400;
ud.wallStart = now * 86400;
ud.lastRatio = -1;
fig.UserData = ud;
end

function fig = local_build(opts, msg)
% Compact uifigure Tag='progress_bar', HandleVisibility off. Title row
% (message + percent), meta row (caller / ETA / CPU%), then the bar from
% local_make_bar (uihtml Data=0–100, or two uilabel cells).

theme = local_theme();
font_size = max(11, double(opts.font_size));
meta_size = max(10, font_size - 1);

fig = uifigure( ...
    'WindowStyle', 'normal', ...
    'Units', 'pixels', ...
    'Position', opts.position, ...
    'Visible', 'off', ...
    'Name', local_task_name(opts.task_id), ...
    'NumberTitle', 'off', ...
    'IntegerHandle', 'off', ...
    'HandleVisibility', 'off', ...
    'Tag', 'progress_bar', ...
    'Color', theme.bg, ...
    'Resize', 'off', ...
    'AutoResizeChildren', 'off');

try
    if isprop(fig, 'DockControls')
        fig.DockControls = 'off';
    end
catch
end

try
    icon_file = which('zeffiro_small_logo.png');
    if isempty(icon_file)
        icon_file = which('zeffiro_logo_compass.png');
    end
    if ~isempty(icon_file) && isprop(fig, 'Icon')
        fig.Icon = icon_file;
    end
catch
end

local_addprop(fig, 'ZefWaitbarStartTime');
local_addprop(fig, 'ZefWaitbarCurrentProgress');
local_addprop(fig, 'ZefWaitbarValue');
local_addprop(fig, 'ZefWaitbarNestLevel');
local_addprop(fig, 'ZefWaitbarOwner');
local_addprop(fig, 'ZefWaitbarNestedOwners');
fig.ZefWaitbarStartTime = now;
fig.ZefWaitbarCurrentProgress = 0;
fig.ZefWaitbarValue = 0;
fig.ZefWaitbarNestLevel = 1;
fig.ZefWaitbarOwner = opts.owner;
fig.ZefWaitbarNestedOwners = {};
fig.CloseRequestFcn = @(src, ~) local_on_close(src);
fig.DeleteFcn = '';

gl = uigridlayout(fig, [3 1]);
gl.Tag = 'zef_ui_root';
gl.RowHeight = {24, 14, 18};
gl.Padding = [18 16 18 16];
gl.RowSpacing = 6;
gl.ColumnSpacing = 0;
try
    gl.BackgroundColor = theme.bg;
catch
end

title_row = uigridlayout(gl, [1 2]);
title_row.ColumnWidth = {'1x', 'fit'};
title_row.ColumnSpacing = 8;
title_row.Padding = [0 0 0 0];
title_row.RowSpacing = 0;
try
    title_row.BackgroundColor = theme.bg;
catch
end

msg_label = uilabel(title_row, ...
    'Text', local_default_msg(msg), ...
    'HorizontalAlignment', 'left', ...
    'FontWeight', 'bold', ...
    'FontSize', font_size, ...
    'FontColor', theme.text, ...
    'Tag', 'progress_bar_text');

pct_label = uilabel(title_row, ...
    'Text', '0%', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'center', ...
    'FontWeight', 'bold', ...
    'FontSize', font_size, ...
    'FontColor', theme.fill, ...
    'Tag', 'progress_bar_percent');

[html_bar, track, fill_bar, empty_bar] = local_make_bar(gl, theme);

meta_row = uigridlayout(gl, [1 2]);
meta_row.ColumnWidth = {'1x', 'fit'};
meta_row.ColumnSpacing = 12;
meta_row.Padding = [0 0 0 0];
meta_row.RowSpacing = 0;
try
    meta_row.BackgroundColor = theme.bg;
catch
end

file_label = uilabel(meta_row, ...
    'Text', opts.caller, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', meta_size, ...
    'FontColor', theme.muted, ...
    'Tag', 'caller_file_name');

ready_label = uilabel(meta_row, ...
    'Text', '', ...
    'HorizontalAlignment', 'right', ...
    'FontSize', meta_size, ...
    'FontColor', theme.muted, ...
    'Tag', 'progress_bar_ready_text');

ud = struct();
ud.msgLabel = msg_label;
ud.htmlBar = html_bar;
ud.barGrid = track;
ud.fillBar = fill_bar;
ud.emptyBar = empty_bar;
ud.pctLabel = pct_label;
ud.fileLabel = file_label;
ud.readyLabel = ready_label;
if local_is_valid(html_bar)
    ud.gauge = html_bar;
else
    ud.gauge = fill_bar;
end
ud.startTime = now;
ud.lastDetailTime = 0;
ud.cpuMark = cputime;
ud.wallMark = now * 86400;
ud.wallStart = now * 86400;
ud.lastRatio = -1;
fig.UserData = ud;
try
    zef_ui_bind_min_size(fig, 440, 100);
catch
end
try
    setappdata(fig, 'ZefMaxSize', [900, 140]);
    if isprop(fig, 'MaxSize')
        fig.MaxSize = [900, 140];
    end
catch
end

end

function theme = local_theme()
theme = struct();
try
    t = zef_ui_theme();
    theme.bg = t.color.bg;
    theme.text = t.color.text;
    theme.muted = t.color.textMuted;
    theme.track = t.color.accentSoft;
    theme.fill = t.color.accent;
catch
    theme.bg = [0.97 0.975 0.978];
    theme.text = [0.14 0.18 0.22];
    theme.muted = [0.42 0.47 0.51];
    theme.track = [0.82 0.87 0.88];
    theme.fill = [0.12 0.52 0.55];
end
end

function local_theme_open()

theme = local_theme();
figs = findall(groot, 'Tag', 'progress_bar');
for i = 1:numel(figs)
    fig = figs(i);
    if ~local_is_valid(fig)
        continue
    end
    try
        fig.Color = theme.bg;
    catch
    end
    grids = findall(fig, 'Type', 'uigridlayout');
    for g = 1:numel(grids)
        try
            grids(g).BackgroundColor = theme.bg;
        catch
        end
    end
    local_set_label_color(fig, 'progress_bar_text', theme.text);
    local_set_label_color(fig, 'progress_bar_percent', theme.fill);
    local_set_label_color(fig, 'caller_file_name', theme.muted);
    local_set_label_color(fig, 'progress_bar_ready_text', theme.muted);
    ud = [];
    try
        ud = fig.UserData;
    catch
    end
    if isstruct(ud) && isfield(ud, 'htmlBar') && local_is_valid(ud.htmlBar)
        try
            pct = ud.htmlBar.Data;
        catch
            pct = 0;
        end
        try
            ud.htmlBar.HTMLSource = local_bar_html(theme);
            ud.htmlBar.Data = pct;
        catch
        end
    end
    try
        local_set_bar(ud, max(0, min(1, double(fig.ZefWaitbarValue) / 100)), theme);
    catch
    end
end

end

function local_set_label_color(fig, tag, rgb)

h = findall(fig, 'Tag', tag);
for i = 1:numel(h)
    try
        h(i).FontColor = rgb;
    catch
    end
end

end

function [html_bar, track, fill_bar, empty_bar] = local_make_bar(parent, theme)
% Prefer a uihtml rounded bar (Data = 0–100). If uihtml is unavailable,
% two uilabel cells in a 1×2 grid approximate the fill (not uigauge).
html_bar = [];
track = [];
fill_bar = [];
empty_bar = [];

try
    html_bar = uihtml(parent);
    html_bar.Tag = 'progress_bar_gauge';
    html_bar.HTMLSource = local_bar_html(theme);
    html_bar.Data = 0;
    return
catch
    html_bar = [];
end

track = uigridlayout(parent, [1 2]);
track.ColumnWidth = {'0.0001x', '1x'};
track.ColumnSpacing = 0;
track.RowSpacing = 0;
track.Padding = [0 0 0 0];
try
    track.BackgroundColor = theme.track;
catch
end
fill_bar = uilabel(track, ...
    'Text', '', ...
    'BackgroundColor', theme.fill, ...
    'Tag', 'progress_bar_gauge');
empty_bar = uilabel(track, ...
    'Text', '', ...
    'BackgroundColor', theme.track);
end

function src = local_bar_html(theme)
src = [ ...
    '<!DOCTYPE html><html><head><meta charset="utf-8"><style>' ...
    'html,body{margin:0;padding:0;width:100%;height:100%;background:transparent;}' ...
    '.wrap{width:100%;height:100%;display:flex;align-items:center;}' ...
    '.track{width:100%;height:12px;background:' local_hex(theme.track) ';' ...
    'border-radius:999px;overflow:hidden;}' ...
    '.fill{height:100%;width:0%;background:' local_hex(theme.fill) ';' ...
    'border-radius:999px;}' ...
    '</style></head><body><div class="wrap"><div class="track">' ...
    '<div class="fill" id="f"></div></div></div><script>' ...
    'function setup(htmlComponent){window.cc=htmlComponent;' ...
    'htmlComponent.addEventListener("DataChanged",paint);paint();}' ...
    'function paint(){var v=window.cc&&window.cc.Data;' ...
    'if(v&&typeof v==="object"&&v.value!=null)v=v.value;' ...
    'v=Math.max(0,Math.min(100,Number(v)||0));' ...
    'var el=document.getElementById("f");if(el)el.style.width=v+"%";}' ...
    '</script></body></html>'];
end

function hex = local_hex(rgb)
hex = sprintf('#%02x%02x%02x', round(255 * rgb(1)), round(255 * rgb(2)), round(255 * rgb(3)));
end

function local_addprop(h, name)
if ~isprop(h, name)
    addprop(h, name);
end
end

function local_set_value_prop(fig, value)
try
    if ~isprop(fig, 'ZefWaitbarValue')
        addprop(fig, 'ZefWaitbarValue');
    end
    fig.ZefWaitbarValue = value;
catch
end
end

function local_set_bar(ud, ratio, theme)
ratio = max(0, min(1, ratio));
pct = 100 * ratio;
if isfield(ud, 'htmlBar') && local_is_valid(ud.htmlBar)
    try
        ud.htmlBar.Data = pct;
    catch
    end
elseif isfield(ud, 'barGrid') && local_is_valid(ud.barGrid)
    try
        ud.barGrid.ColumnWidth = {local_weight(ratio), local_weight(1 - ratio)};
    catch
    end
    try
        ud.fillBar.BackgroundColor = theme.fill;
        ud.emptyBar.BackgroundColor = theme.track;
    catch
    end
end
try
    ud.pctLabel.Text = sprintf('%.0f%%', pct);
    ud.pctLabel.FontColor = theme.fill;
catch
end
end

function w = local_weight(x)
w = sprintf('%.4fx', max(x, 1e-4));
end

function name = local_task_name(~)
name = 'ZEFFIRO Interface: Progress';
end

function local_bump_nest(fig, opts)
% Nested initialize from a different function shares the singleton. Record
% that extra owner so close() from it decrements once; a second close from
% the same nested function (explicit close + onCleanup) must not destroy
% the parent.
try
    owner = '';
    if isprop(fig, 'ZefWaitbarOwner') && ~isempty(fig.ZefWaitbarOwner)
        owner = char(string(fig.ZefWaitbarOwner));
    end
    caller = '';
    if isfield(opts, 'owner') && ~isempty(opts.owner)
        caller = char(string(opts.owner));
    end
    if isempty(caller) || strcmp(caller, owner)
        return
    end
    local_addprop(fig, 'ZefWaitbarNestLevel');
    local_addprop(fig, 'ZefWaitbarNestedOwners');
    nest = 1;
    if ~isempty(fig.ZefWaitbarNestLevel)
        nest = double(fig.ZefWaitbarNestLevel);
    end
    nested = {};
    if ~isempty(fig.ZefWaitbarNestedOwners)
        nested = fig.ZefWaitbarNestedOwners;
        if ~iscell(nested)
            nested = {};
        end
    end
    fig.ZefWaitbarNestedOwners = [nested, {caller}];
    fig.ZefWaitbarNestLevel = nest + 1;
catch
end
end

function local_on_close(src)
% Nested close() drops that caller from ZefWaitbarNestedOwners. A second
% close from the same nested function is a no-op. The original owner, or
% an unknown closer (window X), destroys the figure.
try
    if ~isvalid(src)
        return
    end
    [~, closer] = local_caller_identity();
    nested = {};
    try
        if isprop(src, 'ZefWaitbarNestedOwners') && ~isempty(src.ZefWaitbarNestedOwners)
            nested = src.ZefWaitbarNestedOwners;
            if ~iscell(nested)
                nested = {};
            end
        end
    catch
        nested = {};
    end
    owner = '';
    try
        if isprop(src, 'ZefWaitbarOwner') && ~isempty(src.ZefWaitbarOwner)
            owner = char(string(src.ZefWaitbarOwner));
        end
    catch
        owner = '';
    end
    idx = [];
    if ~isempty(nested)
        idx = find(strcmp(nested, closer), 1, 'last');
    end
    if ~isempty(idx)
        nested(idx) = [];
        src.ZefWaitbarNestedOwners = nested;
        nest = 1;
        if isprop(src, 'ZefWaitbarNestLevel') && ~isempty(src.ZefWaitbarNestLevel)
            nest = double(src.ZefWaitbarNestLevel);
        end
        src.ZefWaitbarNestLevel = max(1, nest - 1);
        return
    end
    if ~(strcmp(closer, owner) || strcmp(closer, 'unknown') || isempty(closer))
        return
    end
    src.CloseRequestFcn = '';
    src.DeleteFcn = '';
    delete(src);
catch
end
end

function local_paint(fig, ratio, msg, opts, first_step)
% ratio is already a scalar in [0,1] (max of nested current./max).
% Bar width and percent label update every call; ETA / CPU% every 5 s.

if ~local_is_valid(fig)
    return
end

ud = fig.UserData;
if ~isstruct(ud) || ~isfield(ud, 'pctLabel') || ~local_is_valid(ud.pctLabel)
    return
end

theme = local_theme();
local_set_bar(ud, ratio, theme);
local_set_value_prop(fig, 100 * ratio);
ud.lastRatio = ratio;

if strlength(string(msg)) > 0
    try
        ud.msgLabel.Text = char(string(msg));
    catch
    end
end

detail_dt = 5;
now_days = now;
do_detail = first_step || ((now_days - ud.lastDetailTime) * 86400 >= detail_dt);

ready_text = '';
var_2 = 0;
var_3 = 0;
if do_detail
    ud.lastDetailTime = now_days;
    var_2 = round(now_days * 86400 - ud.wallStart);
    dt = max(now_days * 86400 - ud.wallMark, eps);
    var_3 = round(100 * (cputime - ud.cpuMark) / dt);
    ud.cpuMark = cputime;
    ud.wallMark = now_days * 86400;

    try
        ud.fileLabel.Text = opts.caller;
    catch
    end

    if ratio <= 0
        ready_text = '';
        try
            ud.readyLabel.Text = '';
        catch
        end
    elseif ratio >= 1
        ready_text = 'Done';
        try
            ud.readyLabel.Text = 'Done';
        catch
        end
    elseif isprop(fig, 'ZefWaitbarStartTime')
        try
            elapsed = max(0, (now_days - fig.ZefWaitbarStartTime) * 86400);
            remaining = ((1 - ratio) / max(ratio, eps)) * elapsed;
            if elapsed < 2.5 || ratio < 0.05
                ready_text = '';
                ud.readyLabel.Text = '';
            else
                ready_text = local_eta_text(remaining, ratio);
                ud.readyLabel.Text = ready_text;
            end
        catch
            ud.readyLabel.Text = '';
        end
    end
end

fig.UserData = ud;

if opts.visible
    try
        drawnow limitrate
    catch
    end
end

if do_detail
    local_log(opts, ratio, msg, var_2, var_3, ready_text);
end

end

function txt = local_eta_text(remaining_sec, ratio)
if nargin < 2
    ratio = 0;
end
if ~isfinite(remaining_sec) || remaining_sec < 0
    txt = '';
    return
end
remaining_sec = round(remaining_sec);
if remaining_sec < 2 && ratio >= 0.9
    txt = 'Almost done';
elseif remaining_sec < 2
    txt = '';
elseif remaining_sec < 60
    txt = sprintf('%d s left', remaining_sec);
elseif remaining_sec < 3600
    m = floor(remaining_sec / 60);
    s = rem(remaining_sec, 60);
    txt = sprintf('%d min %d s left', m, s);
else
    h = floor(remaining_sec / 3600);
    m = floor(rem(remaining_sec, 3600) / 60);
    txt = sprintf('%d h %d min left', h, m);
end
end

function msg = local_default_msg(msg)
if strlength(string(msg)) == 0
    msg = 'Working...';
else
    msg = char(string(msg));
end
end

function local_log(opts, ratio, msg, task_time, cpu_usage, ready_text)

output_line = sprintf([ ...
    'Task ID; %s; Progress; %s; File; %s; Message; %s; Workspace size; 0; ', ...
    'Task time; %s; CPU usage; %s; Ready; %s; Total CPU time; %g;'], ...
    num2str(opts.task_id), num2str(round(100 * ratio)), opts.caller, ...
    char(string(msg)), num2str(task_time), num2str(cpu_usage), ready_text, ...
    max(0, cputime - opts.restart_time));

if opts.use_log && ~isempty(opts.log_file)
    try
        fid = fopen(opts.log_file, 'a');
        if fid ~= -1
            fprintf(fid, '%s\n', output_line);
            fclose(fid);
        end
    catch
    end
end

if opts.verbose && ~opts.visible
    disp(output_line);
end

end
