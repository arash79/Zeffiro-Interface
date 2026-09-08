function varargout = zef_ui_shell(action, varargin)
%ZEF_UI_SHELL  Unified application chrome: header, nav, workspace, footer.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   The left nav is a live view of the Menu tool uimenu tree. Plugins
%   added by zef_plugin appear automatically because flyouts are built
%   from the actual menu children at click time. Callbacks, Tags, and
%   handles are not duplicated.
%
%   zef_ui_shell('build', h_fig)
%   zef_ui_shell('bind', zef)
%   zef_ui_shell('layout', h_fig)
%   zef_ui_shell('hide_menu', zef)
%   zef_ui_shell('hide_companions', zef)
%   zef_ui_shell('dismiss', h_fig)
%   zef_ui_shell('theme', h_fig)
%   zef_ui_shell('raise_figure')
%
%   See also zef_figure_tool, zef_menu_tool, zef_ui_theme.

if nargin < 1 || isempty(action)
    action = 'build';
end
action = lower(char(string(action)));

switch action
    case 'build'
        local_build(varargin{:});
    case 'bind'
        local_bind(varargin{:});
    case 'layout'
        local_layout(varargin{:});
    case 'hide_menu'
        local_hide_menu(varargin{:});
    case 'hide_companions'
        local_hide_companions(varargin{:});
    case 'dismiss'
        local_dismiss(varargin{:});
    case 'theme'
        local_theme(varargin{:});
    case 'place_toolbar'
        local_refresh_toolbar(varargin{:});
    case 'raise_figure'
        local_raise_figure();
    case 'content_rect'
        [varargout{1:nargout}] = local_content_rect(varargin{:});
    otherwise
        error('zef_ui_shell:UnknownAction', 'Unknown action: %s', action);
end

end

function local_build(h_fig)

if nargin < 1 || isempty(h_fig) || ~isgraphics(h_fig) || ~isvalid(h_fig)
    return
end
if ~isempty(zef_ui_find(h_fig, 'zef_shell_nav'))
    return
end

theme = zef_ui_theme();
h_fig.Color = theme.color.bg;
setappdata(h_fig, 'ZefUnifiedShell', true);

header = uipanel('Parent', h_fig, 'Units', 'pixels', 'BorderType', 'none', ...
    'HighlightColor', theme.color.headerBg, 'BackgroundColor', theme.color.headerBg, ...
    'ForegroundColor', theme.color.text, 'Title', '', 'Tag', 'zef_shell_header');
nav = uipanel('Parent', h_fig, 'Units', 'pixels', 'BorderType', 'none', ...
    'HighlightColor', theme.color.bg, 'BackgroundColor', theme.color.bg, ...
    'ForegroundColor', theme.color.text, 'Title', '', 'Tag', 'zef_shell_nav');
card = uipanel('Parent', h_fig, 'Units', 'pixels', 'BorderType', 'none', ...
    'BackgroundColor', theme.color.bg, 'ForegroundColor', theme.color.text, ...
    'Title', '', 'Tag', 'zef_shell_card');
tabs = uipanel('Parent', h_fig, 'Units', 'pixels', 'BorderType', 'none', ...
    'BackgroundColor', theme.color.workspace, 'ForegroundColor', theme.color.text, ...
    'Title', '', 'Tag', 'zef_shell_tabs');
tools = uipanel('Parent', h_fig, 'Units', 'pixels', 'BorderType', 'none', ...
    'BackgroundColor', theme.color.workspace, 'ForegroundColor', theme.color.text, ...
    'Title', '', 'Tag', 'zef_shell_toolbar');
footer = uipanel('Parent', h_fig, 'Units', 'pixels', 'BorderType', 'none', ...
    'HighlightColor', theme.color.footerBg, 'BackgroundColor', theme.color.footerBg, ...
    'ForegroundColor', theme.color.textMuted, 'Title', '', 'Tag', 'zef_shell_footer');

try
    header.AutoResizeChildren = 'off';
    nav.AutoResizeChildren = 'off';
    card.AutoResizeChildren = 'off';
    tabs.AutoResizeChildren = 'off';
    tools.AutoResizeChildren = 'off';
    footer.AutoResizeChildren = 'off';
catch
end

local_build_header(header, theme);
local_build_nav(nav, theme);
local_build_tabs(tabs, theme);
local_build_toolbar(tools, h_fig, theme);
local_build_footer(footer, theme);

try
    ax = zef_ui_find(h_fig, 'axes1');
    if ~isempty(ax) && isvalid(ax)
        ax.Color = theme.color.axesBg;
        try
            ax.Toolbar.Visible = 'off';
        catch
        end
    end
catch
end

prev = get(h_fig, 'WindowButtonDownFcn');
setappdata(h_fig, 'ZefShellPrevDownFcn', prev);
h_fig.WindowButtonDownFcn = @(src, evt) local_window_down(src, evt);
try
    prevk = get(h_fig, 'WindowKeyPressFcn');
    setappdata(h_fig, 'ZefShellPrevKeyFcn', prevk);
    h_fig.WindowKeyPressFcn = @(src, evt) local_window_key(src, evt);
catch
end
try
    local_ensure_flyout_wheel(h_fig);
catch
end
local_install_nav_hover(h_fig);
local_restore_axes(h_fig);

end

function local_build_header(header, theme)

local_make_icon_btn(header, 'zef_shell_header_mark', theme.color.headerBg, false);
uicontrol('Style', 'text', 'Parent', header, 'Units', 'pixels', ...
    'String', 'ZEFFIRO', 'HorizontalAlignment', 'left', 'FontWeight', 'bold', ...
    'ForegroundColor', theme.color.text, 'BackgroundColor', theme.color.headerBg, ...
    'Tag', 'zef_shell_title', 'FontName', theme.font.name, ...
    'FontUnits', 'pixels', 'FontSize', theme.font.sizeTitle + 2);
uicontrol('Style', 'text', 'Parent', header, 'Units', 'pixels', ...
    'String', 'I N T E R F A C E', 'HorizontalAlignment', 'left', ...
    'ForegroundColor', theme.color.accent, 'BackgroundColor', theme.color.headerBg, ...
    'Tag', 'zef_shell_header_sub', 'FontName', theme.font.name, ...
    'FontUnits', 'pixels', 'FontSize', theme.font.sizeSmall);

sun = local_make_icon_btn(header, 'zef_shell_theme_sun', theme.color.headerBg, false);
try
    sun.Enable = 'on';
    sun.Callback = @local_theme_pill;
    sun.TooltipString = 'Theme';
    sun.BusyAction = 'cancel';
catch
end
uicontrol('Style', 'pushbutton', 'Parent', header, 'Units', 'pixels', ...
    'String', '', 'Tag', 'zef_shell_theme_pill', ...
    'Callback', @local_theme_pill, 'BackgroundColor', theme.color.headerBg, ...
    'ForegroundColor', theme.color.text, 'TooltipString', 'Theme');
uicontrol('Style', 'text', 'Parent', header, 'Units', 'pixels', ...
    'String', ['Theme  ' char(9662)], 'HorizontalAlignment', 'left', ...
    'ForegroundColor', theme.color.text, ...
    'BackgroundColor', theme.color.panel, 'Tag', 'zef_shell_theme_label', ...
    'FontName', theme.font.name, 'FontUnits', 'pixels', ...
    'FontSize', theme.font.sizeSmall, 'Enable', 'inactive', ...
    'ButtonDownFcn', @local_theme_pill);

mode = 'Light';
try
    if strcmp(theme.mode, 'dark')
        mode = 'Dark';
    end
catch
end
uicontrol('Style', 'popupmenu', 'Parent', header, 'Units', 'pixels', ...
    'String', {'Light', 'Dark'}, 'Value', 1 + strcmpi(mode, 'Dark'), ...
    'BackgroundColor', theme.color.inputBg, 'ForegroundColor', theme.color.text, ...
    'Tag', 'zef_shell_theme', 'Callback', @local_theme_changed, ...
    'FontName', theme.font.name, 'FontSize', theme.font.sizeSmall);

uicontrol('Style', 'pushbutton', 'Parent', header, 'Units', 'pixels', ...
    'String', '', 'Tag', 'zef_shell_help', ...
    'Callback', 'web(''https://github.com/sampsapursiainen/zeffiro_interface'');', ...
    'BackgroundColor', theme.color.headerBg, 'ForegroundColor', theme.color.text, ...
    'TooltipString', 'Help', 'FontName', theme.font.name, 'FontSize', theme.font.sizeSmall);
uicontrol('Style', 'pushbutton', 'Parent', header, 'Units', 'pixels', ...
    'String', '', 'Tag', 'zef_shell_bell', ...
    'Callback', @local_open_log, ...
    'BackgroundColor', theme.color.headerBg, 'ForegroundColor', theme.color.text, ...
    'TooltipString', 'Session log', 'FontName', theme.font.name, 'FontSize', theme.font.sizeSmall);
uicontrol('Style', 'pushbutton', 'Parent', header, 'Units', 'pixels', ...
    'String', '', 'Tag', 'zef_shell_profile', ...
    'Callback', @local_open_profile, ...
    'BackgroundColor', theme.color.headerBg, 'ForegroundColor', theme.color.text, ...
    'TooltipString', 'Init profile', 'FontName', theme.font.name, 'FontSize', theme.font.sizeSmall);
uicontrol('Style', 'text', 'Parent', header, 'Units', 'pixels', ...
    'String', '', 'Enable', 'inactive', 'Tag', 'zef_header_rule', ...
    'BackgroundColor', theme.color.border);
for tag = {'zef_shell_help', 'zef_shell_bell', 'zef_shell_profile', 'zef_shell_theme_pill'}
    b = findall(header, 'Tag', tag{1});
    if ~isempty(b)
        try
            b(1).BusyAction = 'cancel';
        catch
        end
    end
end

end

function local_build_nav(nav, theme)

local_make_icon_btn(nav, 'zef_shell_brand_mark', theme.color.navBg, false);
uicontrol('Style', 'text', 'Parent', nav, 'Units', 'pixels', ...
    'String', 'ZEFFIRO', 'HorizontalAlignment', 'left', 'FontWeight', 'bold', ...
    'ForegroundColor', theme.color.text, 'BackgroundColor', theme.color.navBg, ...
    'Tag', 'zef_shell_brand_title', 'FontName', theme.font.name, ...
    'FontUnits', 'pixels', 'FontSize', theme.font.sizeTitle);
uicontrol('Style', 'text', 'Parent', nav, 'Units', 'pixels', ...
    'String', 'INTERFACE', 'HorizontalAlignment', 'left', ...
    'ForegroundColor', theme.color.accent, 'BackgroundColor', theme.color.navBg, ...
    'Tag', 'zef_shell_brand_sub', 'FontName', theme.font.name, ...
    'FontUnits', 'pixels', 'FontSize', theme.font.sizeSmall);

items = local_nav_spec();
for i = 1:size(items, 1)
    key = items{i, 1};
    label = items{i, 2};
    field = items{i, 3};
    row = uipanel('Parent', nav, 'Units', 'pixels', 'BorderType', 'none', ...
        'Title', '', 'Tag', ['zef_nav_row_' key], 'UserData', field, ...
        'BackgroundColor', theme.color.panel, 'ForegroundColor', theme.color.text, ...
        'HighlightColor', theme.color.panel, 'ButtonDownFcn', @local_nav_click);
    try
        row.AutoResizeChildren = 'off';
        row.BorderWidth = 0;
        row.BorderColor = theme.color.panel;
    catch
    end
    hit = uicontrol('Style', 'pushbutton', 'Parent', row, 'Units', 'pixels', ...
        'String', '', 'Tag', ['zef_nav_hit_' key], 'UserData', field, ...
        'BackgroundColor', theme.color.panel, 'ForegroundColor', theme.color.panel, ...
        'Callback', @local_nav_click, 'TooltipString', label);
    try
        hit.BusyAction = 'cancel';
    catch
    end
    ic = local_make_icon_btn(row, ['zef_nav_icon_' key], theme.color.panel, true);
    ic.UserData = field;
    ic.Callback = @local_nav_click;
    ic.TooltipString = label;
    btn = uicontrol('Style', 'text', 'Parent', row, 'Units', 'pixels', ...
        'String', label, 'HorizontalAlignment', 'left', 'Enable', 'inactive', ...
        'Tag', ['zef_nav_' key], 'UserData', field, ...
        'BackgroundColor', theme.color.panel, 'ForegroundColor', theme.color.text, ...
        'FontName', theme.font.name, 'FontUnits', 'pixels', ...
        'FontSize', theme.font.size, 'Callback', @local_nav_click, ...
        'ButtonDownFcn', @local_nav_click, 'TooltipString', label);
    try
        uistack(hit, 'bottom');
    catch
    end
end
uicontrol('Style', 'text', 'Parent', nav, 'Units', 'pixels', ...
    'String', '', 'Enable', 'inactive', 'Tag', 'zef_nav_sep', ...
    'BackgroundColor', theme.color.border);

end

function items = local_nav_spec()

items = { ...
    'project', 'Project', 'h_menu_project'; ...
    'export', 'Export', 'h_menu_export'; ...
    'import', 'Import', 'h_menu_import'; ...
    'edit', 'Edit', 'h_menu_edit'; ...
    'inverse', 'Inverse Tools', 'h_menu_inverse_tools'; ...
    'forward', 'Forward Tools', 'h_menu_forward_tools'; ...
    'multi', 'Multi-Tools', 'h_menu_multi_tools'; ...
    'settings', 'Settings', 'h_menu_settings'; ...
    'window', 'Window', 'h_menu_window'; ...
    'help', 'Help', 'h_menu_help'};

end

function local_build_tabs(tabs, theme)

uicontrol('Style', 'text', 'Parent', tabs, 'Units', 'pixels', ...
    'String', 'Figure', 'Tag', 'zef_tab_figure', 'UserData', 1, ...
    'Enable', 'inactive', 'HorizontalAlignment', 'center', ...
    'ForegroundColor', theme.color.accent, 'BackgroundColor', theme.color.workspace, ...
    'FontWeight', 'bold', 'FontName', theme.font.name, ...
    'FontSize', theme.font.size);
uicontrol('Style', 'text', 'Parent', tabs, 'Units', 'pixels', ...
    'String', '', 'Enable', 'inactive', 'BackgroundColor', theme.color.accent, ...
    'Tag', 'zef_tab_underline');
uicontrol('Style', 'text', 'Parent', tabs, 'Units', 'pixels', ...
    'String', '', 'Enable', 'inactive', 'BackgroundColor', theme.color.border, ...
    'Tag', 'zef_tab_rule');

end

function local_build_toolbar(tools, h_fig, theme)

spec = { ...
    'pan', 'Pan', @local_tool_pan, 'pushbutton'; ...
    'rotate', 'Rotate', @local_tool_rotate, 'pushbutton'; ...
    'zoom', 'Zoom', @local_tool_zoom, 'pushbutton'; ...
    'reset', 'Reset View', @local_tool_reset, 'pushbutton'; ...
    'screenshot', 'Screenshot', @local_tool_screenshot, 'pushbutton'; ...
    'colormap', 'Colormap', @local_tool_colormap, 'pushbutton'; ...
    'measure', 'Measure', @local_tool_measure, 'pushbutton'; ...
    'annotate', 'Annotate', @local_tool_annotate, 'pushbutton'; ...
    'edges', 'Toggle Edges', @local_tool_edges, 'pushbutton'};
for i = 1:size(spec, 1)
    btn = uicontrol('Style', spec{i, 4}, 'Parent', tools, 'Units', 'pixels', ...
        'String', '', 'Tag', ['zef_tool_' spec{i, 1}], ...
        'BackgroundColor', theme.color.workspace, 'ForegroundColor', theme.color.text, ...
        'FontName', theme.font.name, 'FontSize', theme.font.sizeSmall, ...
        'Callback', spec{i, 3}, 'TooltipString', spec{i, 2});
    try
        btn.BusyAction = 'cancel';
    catch
    end
    btn.UserData = 0;
    lab = uicontrol('Style', 'text', 'Parent', tools, 'Units', 'pixels', ...
        'String', spec{i, 2}, 'Tag', ['zef_tool_lab_' spec{i, 1}], ...
        'BackgroundColor', theme.color.workspace, 'ForegroundColor', theme.color.text, ...
        'FontName', theme.font.name, 'FontUnits', 'pixels', ...
        'FontSize', theme.font.sizeSmall, 'HorizontalAlignment', 'left', ...
        'Enable', 'inactive', 'ButtonDownFcn', @(s, e) local_tool_from_label(s, spec{i, 1}), ...
        'TooltipString', spec{i, 2});
    lab.UserData = spec{i, 1};
end
uicontrol('Style', 'text', 'Parent', tools, 'Units', 'pixels', ...
    'String', '', 'Enable', 'inactive', 'Tag', 'zef_tool_sep', ...
    'BackgroundColor', theme.color.border);
uicontrol('Style', 'text', 'Parent', tools, 'Units', 'pixels', ...
    'String', '', 'Enable', 'inactive', 'Tag', 'zef_tool_rule', ...
    'BackgroundColor', theme.color.border);
uicontrol('Style', 'pushbutton', 'Parent', tools, 'Units', 'pixels', ...
    'String', '', 'Tag', 'zef_tool_sliders', ...
    'Callback', 'zef_toggle_figure_controls;', ...
    'BackgroundColor', theme.color.workspace, 'ForegroundColor', theme.color.text, ...
    'TooltipString', 'Toggle controls');
uicontrol('Style', 'pushbutton', 'Parent', tools, 'Units', 'pixels', ...
    'String', '', 'Tag', 'zef_tool_more', ...
    'Callback', @(src, ~) local_tool_more(src, h_fig), ...
    'BackgroundColor', theme.color.workspace, 'ForegroundColor', theme.color.text, ...
    'TooltipString', 'More');
for tag = {'zef_tool_sliders', 'zef_tool_more'}
    b = findall(tools, 'Tag', tag{1});
    if ~isempty(b)
        try
            b(1).BusyAction = 'cancel';
        catch
        end
    end
end

end

function local_build_footer(footer, theme)

ver_str = 'Zeffiro Interface';
try
    zef = evalin('base', 'zef');
    if isfield(zef, 'current_version')
        ver_str = sprintf('Zeffiro Interface v%s', num2str(zef.current_version));
    end
catch
end
uicontrol('Style', 'text', 'Parent', footer, 'Units', 'pixels', ...
    'String', ver_str, 'HorizontalAlignment', 'left', ...
    'ForegroundColor', theme.color.textMuted, 'BackgroundColor', theme.color.footerBg, ...
    'Tag', 'zef_shell_version', 'FontName', theme.font.name, ...
    'FontUnits', 'pixels', 'FontSize', theme.font.sizeSmall);
uicontrol('Style', 'text', 'Parent', footer, 'Units', 'pixels', ...
    'String', '© 2018–2026 Sampsa Pursiainen & ZI Development Team', ...
    'HorizontalAlignment', 'center', 'ForegroundColor', theme.color.textMuted, ...
    'BackgroundColor', theme.color.footerBg, 'Tag', 'zef_shell_copy', ...
    'FontName', theme.font.name, 'FontUnits', 'pixels', ...
    'FontSize', theme.font.sizeSmall);

end

function local_bind(zef)

if nargin < 1 || isempty(zef)
    try
        zef = evalin('base', 'zef');
    catch
        return
    end
end
if ~isstruct(zef) || ~isfield(zef, 'h_zeffiro') || ~local_ok(zef.h_zeffiro)
    return
end
h_fig = zef.h_zeffiro;
items = local_nav_spec();
for i = 1:size(items, 1)
    for prefix = {'zef_nav_', 'zef_nav_icon_', 'zef_nav_hit_', 'zef_nav_row_'}
        btn = zef_ui_find(h_fig, [prefix{1} items{i, 1}]);
        if isempty(btn) || ~isvalid(btn)
            continue
        end
        field = items{i, 3};
        h_menu = [];
        if isfield(zef, field) && local_ok(zef.(field))
            h_menu = zef.(field);
        end
        try
            setappdata(btn, 'ZefMenuHandle', h_menu);
        catch
        end
        btn.UserData = field;
    end
end
local_hide_menu(zef);
local_hide_companions(zef);
try
    assignin('base', 'zef', zef);
catch
end

end

function local_hide_menu(zef)

if nargin < 1 || isempty(zef)
    try
        zef = evalin('base', 'zef');
    catch
        return
    end
end
if ~isstruct(zef) || ~isfield(zef, 'h_zeffiro_menu') || ~local_ok(zef.h_zeffiro_menu)
    return
end
h_menu = zef.h_zeffiro_menu;
try
    h_menu.Visible = 'off';
catch
end
try
    h_menu.HandleVisibility = 'off';
catch
end
try
    if isprop(h_menu, 'WindowState')
        h_menu.WindowState = 'normal';
    end
catch
end

end

function local_hide_companions(zef)

if nargin < 1 || isempty(zef)
    try
        zef = evalin('base', 'zef');
    catch
        return
    end
end
if ~isstruct(zef)
    return
end
fields = {'h_zeffiro_window_main', 'h_mesh_tool', 'h_mesh_visualization_tool'};
for i = 1:numel(fields)
    if ~isfield(zef, fields{i})
        continue
    end
    h = zef.(fields{i});
    if ~local_ok(h)
        continue
    end
    try
        h.Visible = 'off';
    catch
    end
end
local_hide_menu(zef);

end

function local_layout(h_fig)

if nargin < 1 || isempty(h_fig) || ~isgraphics(h_fig) || ~isvalid(h_fig)
    return
end
if ~zef_ui_is_unified(h_fig)
    return
end
try
    fly = getappdata(h_fig, 'ZefFlyoutPanel');
    if ~isempty(fly) && isgraphics(fly) && isvalid(fly)
        local_dismiss(h_fig);
    end
catch
end

theme = zef_ui_theme();
orig = h_fig.Units;
h_fig.Units = 'pixels';
pos = h_fig.Position;
W = max(pos(3), 1);
H = max(pos(4), 1);

header_h = theme.space.headerH;
footer_h = theme.space.footerH;
nav_w = theme.space.navW;
show_labels = W >= 860;
if W < 860
    nav_w = theme.space.navWCompact;
    show_labels = false;
end

header = zef_ui_find(h_fig, 'zef_shell_header');
nav = zef_ui_find(h_fig, 'zef_shell_nav');
work = zef_ui_find(h_fig, 'zef_shell_card');
tabs = zef_ui_find(h_fig, 'zef_shell_tabs');
tools = zef_ui_find(h_fig, 'zef_shell_toolbar');
footer = zef_ui_find(h_fig, 'zef_shell_footer');
right_inset = local_right_inset(h_fig);
gap = 12;
try
    gap = theme.space.cardGap;
    rad = theme.space.cardRadius;
catch
    rad = 10;
end
top_gap = gap;
try
    top_gap = theme.space.headerGap;
catch
end

if local_ok(header)
    header.Units = 'pixels';
    header.Position = [0, H - header_h, W, header_h];
    local_place_header(header, theme);
end
if local_ok(nav)
    nav.Units = 'pixels';
    nav.Position = [gap, footer_h + gap, nav_w, max(40, H - header_h - footer_h - gap - top_gap)];
    try
        zef_ui_card(nav, theme);
    catch
    end
    local_place_nav(nav, theme, show_labels);
    local_install_nav_hover(h_fig);
end
if local_ok(footer)
    footer.Units = 'pixels';
    footer.Position = [0, 0, W, footer_h];
    local_place_footer(footer, theme);
end

content_x = nav_w + 2 * gap;
content_w = max(120, W - nav_w - right_inset - 2 * gap);
status_h = theme.space.statusH;
figure_y = footer_h + 2 * gap + status_h;
figure_h = max(80, H - header_h - top_gap - figure_y);
if local_ok(work)
    work.Units = 'pixels';
    work.Position = [content_x, figure_y, content_w, figure_h];
    try
        % Do not paint an opaque full-size card over sibling uiaxes;
        % MATLAB cannot stack uiaxes above a covering panel/uicontrol.
        work.Visible = 'off';
    catch
    end
end
tab_x = content_x;
tab_w = max(80, content_w);
if local_ok(tabs)
    tabs.Units = 'pixels';
    tabs.Position = [tab_x, figure_y + figure_h - theme.space.tabH, tab_w, theme.space.tabH];
    local_place_tabs(tabs, theme);
end
if local_ok(tools)
    tools.Units = 'pixels';
    tools.Position = [tab_x, figure_y + figure_h - theme.space.tabH - theme.space.toolbarH, ...
        tab_w, theme.space.toolbarH];
    local_place_toolbar(tools, theme, tab_w);
end
try
    if ~(isappdata(h_fig, 'ZefChromeRaised') ...
            && isequal(getappdata(h_fig, 'ZefChromeRaised'), true))
        local_raise_chrome(h_fig);
        setappdata(h_fig, 'ZefChromeRaised', true);
    end
catch
    local_raise_chrome(h_fig);
end
try
    zef_ui_card_corners(h_fig, [content_x, figure_y, content_w, figure_h], theme, rad);
catch
end

h_fig.Units = orig;
local_restore_axes(h_fig);

end

function [x, y, w, h] = local_content_rect(h_fig, theme)

if nargin < 2 || isempty(theme)
    theme = zef_ui_theme();
end
orig = h_fig.Units;
h_fig.Units = 'pixels';
p = h_fig.Position;
W = max(p(3), 1);
H = max(p(4), 1);
h_fig.Units = orig;
x = 0;
y = 0;
w = W;
h = H;
if ~zef_ui_is_unified(h_fig)
    return
end
nav_w = theme.space.navW;
if W < 860
    nav_w = theme.space.navWCompact;
end
gap = theme.space.cardGap;
x = nav_w + 2 * gap;
y = theme.space.footerH + 2 * gap + theme.space.statusH;
w = max(80, W - nav_w - local_right_inset(h_fig) - 2 * gap);
h = max(80, H - theme.space.headerH - theme.space.footerH - theme.space.statusH ...
    - theme.space.headerGap - 2 * gap - theme.space.tabH - theme.space.toolbarH);

end

function local_place_header(header, theme)

p = header.Position;
inner_h = p(4);
mark = zef_ui_find(header, 'zef_shell_header_mark');
title = zef_ui_find(header, 'zef_shell_title');
sub = zef_ui_find(header, 'zef_shell_header_sub');
sun = zef_ui_find(header, 'zef_shell_theme_sun');
lab = zef_ui_find(header, 'zef_shell_theme_label');
pop = zef_ui_find(header, 'zef_shell_theme');
pill = zef_ui_find(header, 'zef_shell_theme_pill');
helpb = zef_ui_find(header, 'zef_shell_help');
bellb = zef_ui_find(header, 'zef_shell_bell');
profb = zef_ui_find(header, 'zef_shell_profile');
y = max(8, round((inner_h - 24) / 2) + 1);
x_right = p(3) - 12;
right_icons = {profb, 'profile'; bellb, 'bell'; helpb, 'help'};
for i = 1:size(right_icons, 1)
    hb = right_icons{i, 1};
    if local_ok(hb)
        hb.Position = [x_right - 24, y, 24, 24];
        hb.String = '';
        hb.Enable = 'on';
        hb.BackgroundColor = theme.color.headerBg;
        local_show_icon(hb, right_icons{i, 2}, 22, theme.color.text, theme.color.headerBg);
        x_right = x_right - 30;
    end
end
if local_ok(pop)
    pop.Visible = 'off';
    pop.Position = [x_right - 8, y, 8, 22];
end
pill_w = 88;
pill_h = 22;
pill_x = x_right - pill_w;
pill_y = max(6, round((inner_h - pill_h) / 2));
fillc = theme.color.panelAlt;
if local_ok(pill)
    pill.Position = [pill_x, pill_y, pill_w, pill_h];
    pill.Callback = @local_theme_pill;
    try
        pkey = [pill_w, pill_h];
        prev = getappdata(pill, 'ZefPillKey');
        if ~isequal(prev, pkey)
            pill.CData = zef_ui_roundrect(pill_w, pill_h, 12, fillc, ...
                theme.color.border, theme.color.headerBg);
            setappdata(pill, 'ZefPillKey', pkey);
        end
        pill.String = '';
        pill.BackgroundColor = theme.color.headerBg;
    catch
    end
end
if local_ok(sun)
    sun_key = 'sun';
    if strcmp(theme.mode, 'dark')
        sun_key = 'moon';
    end
    sun.Enable = 'on';
    sun.Callback = @local_theme_pill;
    sun.Position = [pill_x + 8, pill_y + 2, 20, 20];
    local_show_icon(sun, sun_key, 18, theme.color.text, fillc);
end
if local_ok(lab)
    lab.String = ['Theme  ' char(9662)];
    lab.ForegroundColor = theme.color.text;
    lab.BackgroundColor = fillc;
    lab.Enable = 'inactive';
    lab.ButtonDownFcn = @local_theme_pill;
    lab.Position = [pill_x + 26, pill_y + 1, 58, 20];
end
x0 = 16;
if local_ok(mark)
    mark.Position = [x0, y, 24, 24];
    local_show_icon(mark, 'mark', 22, theme.color.accent, theme.color.headerBg);
    x0 = x0 + 28;
end
if local_ok(title)
    title.String = 'ZEFFIRO';
    title.FontWeight = 'bold';
    title.BackgroundColor = theme.color.headerBg;
    try
        title.FontUnits = 'pixels';
        title.FontSize = theme.font.sizeTitle + 1;
    catch
    end
    title.Position = [x0, y, 86, 20];
    x0 = x0 + 88;
end
if local_ok(sub)
    sub.String = 'I N T E R F A C E';
    sub.ForegroundColor = theme.color.accent;
    sub.BackgroundColor = theme.color.headerBg;
    try
        sub.FontUnits = 'pixels';
        sub.FontSize = theme.font.sizeSmall;
        sub.FontWeight = 'normal';
    catch
    end
    sub.Position = [x0, y + 1, 152, 16];
end
rule = zef_ui_find(header, 'zef_header_rule');
if local_ok(rule)
    show_rule = true;
    try
        show_rule = theme.space.headerGap >= 1;
    catch
    end
    rule.Visible = onoff(show_rule);
    rule.Position = [0, 0, max(1, p(3)), 1];
    rule.BackgroundColor = theme.color.border;
end

end

function local_place_nav(nav, theme, show_labels)

p = nav.Position;
pad = 10;
item_h = theme.space.navItemH;
inner_w = max(36, p(3) - 2 * pad);
mark = zef_ui_find(nav, 'zef_shell_brand_mark');
title = zef_ui_find(nav, 'zef_shell_brand_title');
sub = zef_ui_find(nav, 'zef_shell_brand_sub');
if local_ok(mark)
    mark.Visible = 'off';
end
if local_ok(title)
    title.Visible = 'off';
end
if local_ok(sub)
    sub.Visible = 'off';
end

items = local_nav_spec();
n = size(items, 1);
top_n = 7;
icon_s = 24;
avail = max(40, p(4) - 2 * pad);
top_gap = 5;
group_extra = 16;
needed = n * item_h + (n - 1) * top_gap + group_extra + 2 * pad;
if needed > p(4)
    slack = avail - n * item_h - group_extra;
    if slack >= 0
        top_gap = slack / max(1, n - 1);
    else
        item_h = max(icon_s + 4, floor((avail - group_extra) / n));
        top_gap = 0;
    end
end
ys = zeros(n, 1);
y_top = p(4) - pad - item_h;
for i = 1:n
    ys(i) = y_top;
    y_top = y_top - item_h - top_gap;
    if i == top_n
        y_top = y_top - group_extra;
    end
end
bot_n = n - top_n;
if bot_n > 0
    bot_gap = 5;
    y_bot = pad;
    ys_bot = zeros(bot_n, 1);
    for k = bot_n:-1:1
        ys_bot(k) = y_bot;
        y_bot = y_bot + item_h + bot_gap;
    end
    top_limit = ys(top_n) - group_extra - item_h;
    if ys_bot(1) <= top_limit
        ys(top_n + 1:n) = ys_bot;
    end
end
paint_key = {char(theme.mode), logical(show_labels)};
do_paint = true;
try
    do_paint = ~isequal(getappdata(nav, 'ZefNavPaintKey'), paint_key);
catch
end
for i = 1:n
    key = items{i, 1};
    row = zef_ui_find(nav, ['zef_nav_row_' key]);
    if ~local_ok(row)
        continue
    end
    row.Units = 'pixels';
    row.Position = [pad, max(4, ys(i)), inner_w, item_h];
    try
        row.AutoResizeChildren = 'off';
        row.BorderType = 'none';
        row.BorderWidth = 0;
        row.BorderColor = theme.color.panel;
    catch
    end
    row.UserData = items{i, 3};
    row.ButtonDownFcn = @local_nav_click;
    local_nav_layout_row(row, theme, show_labels, key, items{i, 2}, items{i, 3});
    if do_paint
        local_nav_paint_row(row, theme, key, items{i, 2});
    end
end
sep = zef_ui_find(nav, 'zef_nav_sep');
if local_ok(sep) && (top_n + 1) <= n
    sep.Visible = 'on';
    sep.BackgroundColor = theme.color.border;
    sep_y = ys(top_n + 1) + item_h + max(6, round((ys(top_n) - ys(top_n + 1) - item_h) / 2));
    sep.Position = [pad + 4, sep_y, max(16, inner_w - 8), 1];
end
try
    if do_paint
        setappdata(nav, 'ZefNavPaintKey', paint_key);
    end
catch
end

end

function local_nav_layout_row(row, theme, show_labels, key, label, field)

hit = zef_ui_find(row, ['zef_nav_hit_' key]);
ic = zef_ui_find(row, ['zef_nav_icon_' key]);
btn = zef_ui_find(row, ['zef_nav_' key]);
row.Units = 'pixels';
rp = row.Position;
rw = max(1, rp(3));
rh = max(1, rp(4));
icon_s = 24;
pad_x = 8;
gap = 8;
icon_y = max(0, round((rh - icon_s) / 2));
if show_labels
    icon_x = pad_x;
else
    icon_x = max(0, round((rw - icon_s) / 2));
end
ready = false;
try
    ready = isappdata(row, 'ZefNavRowReady') && isequal(getappdata(row, 'ZefNavRowReady'), true);
catch
end
if local_ok(hit)
    hit.Units = 'pixels';
    hit.Position = [0, 0, rw, rh];
    if ~ready
        hit.UserData = field;
        hit.Callback = @local_nav_click;
        try
            hit.ButtonDownFcn = '';
        catch
        end
        hit.TooltipString = label;
        try
            if ~isappdata(hit, 'ZefHitStacked')
                uistack(hit, 'bottom');
                setappdata(hit, 'ZefHitStacked', true);
            end
        catch
        end
    end
end
if local_ok(ic)
    ic.Units = 'pixels';
    ic.Position = [icon_x, icon_y, icon_s, icon_s];
    if ~ready
        ic.UserData = field;
        ic.Callback = @local_nav_click;
        try
            ic.ButtonDownFcn = '';
        catch
        end
        ic.Enable = 'on';
        ic.TooltipString = label;
    end
end
if local_ok(btn)
    btn.Units = 'pixels';
    if ~ready
        btn.String = label;
        btn.UserData = field;
        btn.HorizontalAlignment = 'left';
        btn.Enable = 'inactive';
        btn.Callback = @local_nav_click;
        btn.ButtonDownFcn = @local_nav_click;
        try
            btn.FontUnits = 'pixels';
            btn.FontSize = theme.font.size;
            btn.FontWeight = 'normal';
        catch
        end
    end
    if show_labels
        lab_x = icon_x + icon_s + gap;
        lab_w = max(24, rw - lab_x - pad_x);
        btn.Position = [lab_x, icon_y, lab_w, icon_s];
        btn.Visible = 'on';
    else
        btn.Visible = 'off';
    end
end
try
    setappdata(row, 'ZefNavRowReady', true);
catch
end

end

function local_nav_paint_row(row, theme, key, label)

if ~local_ok(row)
    return
end
hit = zef_ui_find(row, ['zef_nav_hit_' key]);
ic = zef_ui_find(row, ['zef_nav_icon_' key]);
btn = zef_ui_find(row, ['zef_nav_' key]);
h_fig = ancestor(row, 'figure');
fillc = theme.color.panel;
ink = theme.color.text;
icon_fg = theme.color.navIcon;
hovered = '';
try
    hovered = char(getappdata(h_fig, 'ZefNavHoverKey'));
catch
end
if isempty(hovered)
    try
        nav = ancestor(row, 'figure');
        navp = zef_ui_find(nav, 'zef_shell_nav');
        if local_ok(navp)
            hovered = char(getappdata(navp, 'ZefNavHoverKey'));
        end
    catch
    end
end
is_hover = strcmp(hovered, key);
is_active = false;
try
    src = getappdata(h_fig, 'ZefFlyoutSource');
    is_active = local_ok(src) && isequal(src, row);
catch
end
if is_active
    fillc = theme.color.navActive;
    icon_fg = theme.color.accent;
elseif is_hover
    fillc = theme.color.navHover;
    icon_fg = theme.color.accent;
end
row.BackgroundColor = fillc;
try
    row.HighlightColor = fillc;
    row.BorderColor = fillc;
    row.BorderType = 'none';
    row.BorderWidth = 0;
catch
end
if local_ok(hit)
    hit.Units = 'pixels';
    hp = hit.Position;
    hw = max(8, round(hp(3)));
    hh = max(8, round(hp(4)));
    hit.BackgroundColor = fillc;
    hit.ForegroundColor = fillc;
    try
        r = min(theme.space.btnRadius, max(3, floor(min(hw, hh) / 2) - 1));
        nkey = [hw, hh, round(fillc * 1000)];
        prevk = [];
        try
            prevk = getappdata(hit, 'ZefNavHitKey');
        catch
        end
        if ~isequal(prevk, nkey)
            hit.CData = zef_ui_roundrect(hw, hh, r, fillc, fillc, theme.color.panel);
            setappdata(hit, 'ZefNavHitKey', nkey);
        end
    catch
    end
    hit.TooltipString = label;
end
if local_ok(ic)
    ic.BackgroundColor = fillc;
    local_show_icon(ic, key, 24, icon_fg, fillc);
end
if local_ok(btn)
    btn.BackgroundColor = fillc;
    btn.ForegroundColor = ink;
end

end

function local_install_nav_hover(h_fig)

if ~local_ok(h_fig)
    return
end
try
    if isappdata(h_fig, 'ZefNavHoverListener')
        lh = getappdata(h_fig, 'ZefNavHoverListener');
        if ~isempty(lh) && isvalid(lh)
            return
        end
    end
catch
end
try
    lh = addlistener(h_fig, 'WindowMouseMotion', @(s, ~) local_nav_hover(s));
    setappdata(h_fig, 'ZefNavHoverListener', lh);
    return
catch
end
try
    if isappdata(h_fig, 'ZefShellPrevMotionFcn')
        return
    end
    prev = get(h_fig, 'WindowButtonMotionFcn');
    setappdata(h_fig, 'ZefShellPrevMotionFcn', prev);
    h_fig.WindowButtonMotionFcn = @(src, evt) local_nav_motion_wrap(src, evt);
catch
end

end

function local_nav_motion_wrap(src, evt)

local_nav_hover(src);
prev = [];
try
    prev = getappdata(src, 'ZefShellPrevMotionFcn');
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

function local_nav_hover(src)

h_fig = ancestor(src, 'figure');
if ~local_ok(h_fig)
    h_fig = src;
end
if ~local_ok(h_fig)
    return
end
nav = zef_ui_find(h_fig, 'zef_shell_nav');
if ~local_ok(nav)
    return
end
key = '';
try
    obj = hittest(h_fig);
    key = local_nav_key_of(obj);
catch
end
prev = '';
try
    prev = char(getappdata(nav, 'ZefNavHoverKey'));
catch
end
if strcmp(prev, key)
    try
        zef_ui_interact(h_fig, 'motion');
    catch
    end
    return
end
try
    setappdata(h_fig, 'ZefNavHoverKey', key);
catch
end
try
    setappdata(nav, 'ZefNavHoverKey', key);
catch
end
theme = zef_ui_theme();
items = local_nav_spec();
for i = 1:size(items, 1)
    k = items{i, 1};
    row = zef_ui_find(nav, ['zef_nav_row_' k]);
    if local_ok(row)
        local_nav_paint_row(row, theme, k, items{i, 2});
    end
end
try
    zef_ui_interact(h_fig, 'motion');
catch
end

end

function key = local_nav_key_of(obj)

key = '';
h = obj;
spec = local_nav_spec();
names = spec(:, 1);
prefixes = {'zef_nav_row_', 'zef_nav_hit_', 'zef_nav_icon_', 'zef_nav_'};
for i = 1:10
    if ~local_ok(h)
        return
    end
    tag = '';
    try
        tag = char(h.Tag);
    catch
    end
    for p = 1:numel(prefixes)
        pref = prefixes{p};
        if strncmp(tag, pref, numel(pref))
            rest = tag((numel(pref) + 1):end);
            if any(strcmp(names, rest))
                key = rest;
                return
            end
        end
    end
    try
        h = h.Parent;
    catch
        return
    end
end

end

function row = local_nav_row_of(src)

row = [];
h = src;
for i = 1:10
    if ~local_ok(h)
        return
    end
    tag = '';
    try
        tag = char(h.Tag);
    catch
    end
    if strncmp(tag, 'zef_nav_row_', 12)
        row = h;
        return
    end
    try
        h = h.Parent;
    catch
        return
    end
end

end

function local_place_tabs(tabs, theme)

p = tabs.Position;
h = max(22, p(4) - 4);
fig_tab = zef_ui_find(tabs, 'zef_tab_figure');
und = zef_ui_find(tabs, 'zef_tab_underline');
x = 12;
if local_ok(fig_tab)
    fig_tab.Position = [x, 6, 64, h - 8];
end
if local_ok(und) && local_ok(fig_tab)
    und.Position = [fig_tab.Position(1) + 10, 2, max(28, fig_tab.Position(3) - 20), 3];
    und.BackgroundColor = theme.color.accent;
end
rule = zef_ui_find(tabs, 'zef_tab_rule');
if local_ok(rule)
    rule.Position = [0, 0, max(1, p(3)), 1];
    rule.BackgroundColor = theme.color.border;
end

end

function local_place_toolbar(tools, theme, content_w)

p = tools.Position;
pad = 6;
icon_w = 24;
lab_h = 16;
top_pad = 8;
y_icon = max(2, round((p(4) - icon_w) / 2));
y_lab = max(1, round((p(4) - lab_h) / 2) - 1);
keys = {'pan', 'rotate', 'zoom', 'reset', 'screenshot', 'colormap', ...
    'measure', 'annotate', 'edges'};
more = zef_ui_find(tools, 'zef_tool_more');
sl = zef_ui_find(tools, 'zef_tool_sliders');
ink = theme.color.text;
surface = theme.color.workspace;
right = p(3) - 6;
icon_hit = 24;
if local_ok(more)
    more.Position = [right - icon_hit, y_icon, icon_hit, icon_hit];
    more.String = '';
    more.Enable = 'on';
    more.BackgroundColor = surface;
    local_show_icon(more, 'ellipsis', 22, ink, surface);
    right = right - icon_hit - 4;
end
if local_ok(sl)
    sl.Position = [right - icon_hit, y_icon, icon_hit, icon_hit];
    sl.TooltipString = 'Toggle controls';
    sl.Enable = 'on';
    sl.BackgroundColor = surface;
    local_show_icon(sl, 'sliders', 22, ink, surface);
    right = right - icon_hit - 4;
end
x_limit = right - 2;
x0 = pad;
n = numel(keys);
tw = zeros(1, n);
show = true(1, n);
lab_fs = 10;
tw_ok = false;
try
    if isequal(getappdata(tools, 'ZefToolLabFs'), lab_fs)
        tw_cached = getappdata(tools, 'ZefToolLabW');
        tw_ok = isequal(size(tw_cached), [1, n]);
        if tw_ok
            tw = tw_cached;
        end
    end
catch
end
for i = 1:n
    lab = zef_ui_find(tools, ['zef_tool_lab_' keys{i}]);
    if local_ok(lab)
        lab.String = local_tool_label(keys{i});
        try
            lab.FontUnits = 'pixels';
            lab.FontSize = lab_fs;
            lab.FontName = theme.font.name;
        catch
        end
        if tw_ok
            continue
        end
        tw(i) = 32;
        try
            lab.Position = [0, 0, 280, lab_h];
            tw(i) = max(14, ceil(lab.Extent(3)) + 4);
        catch
            txt = '';
            try
                txt = char(string(lab.String));
            catch
            end
            tw(i) = max(14, ceil((numel(txt) + 1) * lab_fs * 0.58) + 4);
        end
    end
end
if ~tw_ok
    try
        setappdata(tools, 'ZefToolLabW', tw);
        setappdata(tools, 'ZefToolLabFs', lab_fs);
    catch
    end
end
sep_w = 10;
gap_icon_lab = 3;
gap_after = 8;
    function tot = total_w()
        tot = 0;
        for k = 1:n
            tot = tot + icon_w + gap_icon_lab;
            if show(k)
                tot = tot + tw(k);
            else
                tot = tot - gap_icon_lab;
            end
            tot = tot + gap_after;
            if k == 4
                tot = tot + sep_w;
            end
        end
    end
avail = max(40, x_limit - x0);
while total_w() > avail && gap_after > 2
    gap_after = gap_after - 1;
end
while total_w() > avail && lab_fs > 9
    lab_fs = lab_fs - 1;
    for i = 1:n
        lab = zef_ui_find(tools, ['zef_tool_lab_' keys{i}]);
        if local_ok(lab)
            try
                lab.FontSize = lab_fs;
                lab.Position = [0, 0, 240, lab_h];
                tw(i) = max(14, ceil(lab.Extent(3)) + 4);
            catch
                txt = char(string(lab.String));
                tw(i) = max(14, ceil((numel(txt) + 1) * lab_fs * 0.58) + 4);
            end
        end
    end
end
hide_order = 9:-1:1;
hi = 1;
while total_w() > avail && hi <= numel(hide_order)
    show(hide_order(hi)) = false;
    hi = hi + 1;
end
x = x0;
for i = 1:n
    btn = zef_ui_find(tools, ['zef_tool_' keys{i}]);
    lab = zef_ui_find(tools, ['zef_tool_lab_' keys{i}]);
    if ~local_ok(btn)
        continue
    end
    btn.Visible = 'on';
    btn.Enable = 'on';
    try
        btn.ButtonDownFcn = '';
    catch
    end
    btn.Position = [x, y_icon, icon_w, icon_w];
    fill = surface;
    try
        if isequal(btn.UserData, 1) && any(strcmp(keys{i}, ...
                {'pan', 'rotate', 'zoom', 'measure', 'annotate'}))
            fill = theme.color.hover;
        end
    catch
    end
    btn.BackgroundColor = fill;
    btn.String = '';
    local_show_icon(btn, keys{i}, 22, ink, fill);
    room = x_limit - x - 4;
    need = icon_w + gap_icon_lab + tw(i);
    if show(i) && tw(i) > 0 && local_ok(lab) && room >= need
        x = x + icon_w + gap_icon_lab;
        lab.Visible = 'on';
        lab.String = local_tool_label(keys{i});
        lab.Enable = 'inactive';
        lab.ButtonDownFcn = @(s, e) local_tool_from_label(s, keys{i});
        lab.Position = [x, y_lab, tw(i), lab_h];
        lab.BackgroundColor = fill;
        lab.ForegroundColor = ink;
        lab.HorizontalAlignment = 'left';
        try
            lab.FontUnits = 'pixels';
            lab.FontSize = lab_fs;
            lab.FontName = theme.font.name;
        catch
        end
        x = x + tw(i) + gap_after;
    else
        if local_ok(lab)
            lab.Visible = 'off';
        end
        x = x + icon_w + gap_after;
    end
    if i == 4
        sep = zef_ui_find(tools, 'zef_tool_sep');
        if local_ok(sep)
            sep.Position = [x, y_icon + 2, 1, max(12, icon_w - 4)];
            sep.BackgroundColor = theme.color.border;
            x = x + sep_w;
        end
    end
end
rule = zef_ui_find(tools, 'zef_tool_rule');
if local_ok(rule)
    rule.Position = [0, 0, max(1, p(3)), 1];
    rule.BackgroundColor = theme.color.border;
end

end

function local_refresh_toolbar(h_fig)

if nargin < 1 || isempty(h_fig) || ~isgraphics(h_fig) || ~isvalid(h_fig)
    return
end
theme = zef_ui_theme();
tools = zef_ui_find(h_fig, 'zef_shell_toolbar');
if local_ok(tools)
    tools.Units = 'pixels';
    local_place_toolbar(tools, theme, tools.Position(3));
end

end

function local_place_footer(footer, theme)

p = footer.Position;
ver = zef_ui_find(footer, 'zef_shell_version');
copy = zef_ui_find(footer, 'zef_shell_copy');
if local_ok(ver)
    ver.Position = [14, 4, min(220, p(3) * 0.28), max(16, p(4) - 8)];
    ver.ForegroundColor = theme.color.textMuted;
end
if local_ok(copy)
    copy.HorizontalAlignment = 'center';
    copy.Position = [round(p(3) * 0.22), 4, round(p(3) * 0.56), max(16, p(4) - 8)];
    copy.ForegroundColor = theme.color.textMuted;
end

end

function local_nav_click(src, ~)

src = local_hit_src(src);
h_fig = ancestor(src, 'figure');
if local_dup_click(h_fig, src)
    return
end
open_src = [];
try
    open_src = getappdata(h_fig, 'ZefFlyoutSource');
catch
end
local_dismiss(h_fig);
anchor = local_nav_row_of(src);
if ~local_ok(anchor)
    anchor = src;
end
if ~isempty(open_src) && isequal(open_src, anchor)
    setappdata(h_fig, 'ZefFlyoutSource', []);
    return
end

h_menu = [];
try
    h_menu = getappdata(src, 'ZefMenuHandle');
catch
end
if ~local_ok(h_menu) && local_ok(anchor)
    try
        h_menu = getappdata(anchor, 'ZefMenuHandle');
    catch
    end
end
if ~local_ok(h_menu)
    h_menu = local_lookup_menu(src);
end
if ~local_ok(h_menu) && local_ok(anchor)
    h_menu = local_lookup_menu(anchor);
end
if ~local_ok(h_menu)
    return
end
kids = local_menu_children(h_menu);
if isempty(kids)
    local_invoke_menu(h_menu);
    return
end
local_open_flyout(h_fig, anchor, kids, 1);

end

function h_menu = local_lookup_menu(src)

h_menu = [];
field = '';
try
    field = char(src.UserData);
catch
end
if isempty(field)
    return
end
try
    zef = evalin('base', 'zef');
    if isfield(zef, field) && local_ok(zef.(field))
        h_menu = zef.(field);
        setappdata(src, 'ZefMenuHandle', h_menu);
    end
catch
end

end

function kids = local_menu_children(h_menu)

kids = gobjects(0);
try
    ch = allchild(h_menu);
catch
    return
end
keep = false(size(ch));
for i = 1:numel(ch)
    try
        if ~strcmpi(char(ch(i).Type), 'uimenu')
            continue
        end
        vis = 'on';
        if isprop(ch(i), 'Visible')
            vis = char(ch(i).Visible);
        end
        if strcmpi(vis, 'off')
            continue
        end
        txt = strtrim(char(string(ch(i).Text)));
        if isempty(txt)
            continue
        end
        keep(i) = true;
    catch
    end
end
kids = ch(keep);
% allchild is reverse visual order; restore menu order.
kids = flipud(kids(:));

end

function local_open_flyout(h_fig, src, kids, level)

theme = zef_ui_theme();
nav = zef_ui_find(h_fig, 'zef_shell_nav');
src_fig = getpixelposition(src, true);
nav_fig = [0 0 0 0];
if local_ok(nav)
    nav_fig = getpixelposition(nav, true);
end
in_nav = local_ok(nav) && src_fig(1) <= nav_fig(1) + nav_fig(3) + 24;
x = src_fig(1);
if level > 1 && isappdata(h_fig, 'ZefFlyoutPanel')
    prev = getappdata(h_fig, 'ZefFlyoutPanel');
    if local_ok(prev)
        prev.Units = 'pixels';
        x = prev.Position(1) + prev.Position(3) - 1;
        in_nav = true;
    end
elseif in_nav
    x = nav_fig(1) + nav_fig(3) - 1;
end
row_h = 28;
n = numel(kids);
pad = 8;
need = n * row_h + 2 * pad;
avail = max(120, h_fig.Position(4) - theme.space.headerH - theme.space.footerH - 8);
h = min(max(need, 48), avail);
overflow = need > h;
slider_w = 0;
if overflow
    slider_w = 14;
end
labels = cell(n, 1);
for i = 1:n
    labels{i} = local_menu_label(kids(i));
    sub = local_menu_children(kids(i));
    if ~isempty(sub)
        labels{i} = [labels{i} '   ▸']; %#ok<AGROW>
    end
end
w = local_flyout_width(labels, theme);
if in_nav
    y = src_fig(2) + src_fig(4) - h;
else
    y = src_fig(2) - h;
    if y < theme.space.footerH + 4
        y = src_fig(2) + src_fig(4);
    end
end
y = min(max(theme.space.footerH + 4, y), ...
    h_fig.Position(4) - theme.space.headerH - h - 4);
max_x = h_fig.Position(3) - w - 8;
if x > max_x
    if level > 1 && isappdata(h_fig, 'ZefFlyoutPanel')
        prev = getappdata(h_fig, 'ZefFlyoutPanel');
        if local_ok(prev)
            try
                prev.Units = 'pixels';
                left_x = prev.Position(1) - w + 1;
                if left_x >= 8
                    x = left_x;
                else
                    x = max(8, max_x);
                end
            catch
                x = max(8, max_x);
            end
        else
            x = max(8, max_x);
        end
    else
        x = max(8, max_x);
    end
end
x = max(8, min(x, max(8, h_fig.Position(3) - w - 4)));
tag = 'zef_shell_flyout';
if level > 1
    tag = sprintf('zef_shell_flyout_%d', level);
end
local_dismiss_from(h_fig, level);
panel = uipanel('Parent', h_fig, 'Units', 'pixels', 'BorderType', 'none', ...
    'HighlightColor', theme.color.bg, 'BackgroundColor', theme.color.bg, ...
    'Title', '', 'Tag', tag, 'Position', [x, y, w, h]);
try
    panel.AutoResizeChildren = 'off';
catch
end
try
    zef_ui_card(panel, theme, theme.space.cardRadius);
catch
end
item_w = max(48, w - 2 * pad - slider_w);
items = gobjects(n, 1);
yy = h - pad - row_h;
for i = 1:n
    label = labels{i};
    sub = local_menu_children(kids(i));
    b = uicontrol('Style', 'text', 'Parent', panel, 'Units', 'pixels', ...
        'String', ['  ' label], 'HorizontalAlignment', 'left', ...
        'Enable', 'inactive', 'Position', [pad, yy, item_w, row_h], ...
        'BackgroundColor', theme.color.panel, 'ForegroundColor', theme.color.text, ...
        'FontName', theme.font.name, 'FontSize', theme.font.size, ...
        'FontUnits', 'pixels');
    setappdata(b, 'ZefMenuHandle', kids(i));
    if isempty(sub)
        cb = @(s, ~) local_leaf_click(s, h_fig);
    else
        cb = @(s, ~) local_sub_click(s, h_fig, level + 1);
    end
    b.Callback = cb;
    b.ButtonDownFcn = cb;
    try
        b.BusyAction = 'cancel';
    catch
    end
    items(i) = b;
    yy = yy - row_h;
end
max_off = max(0, need - h);
setappdata(panel, 'ZefFlyoutItems', items);
setappdata(panel, 'ZefFlyoutRowH', row_h);
setappdata(panel, 'ZefFlyoutPad', pad);
setappdata(panel, 'ZefFlyoutMaxOff', max_off);
if overflow && max_off > 0
    sl = uicontrol('Style', 'slider', 'Parent', panel, 'Units', 'pixels', ...
        'Min', 0, 'Max', max_off, 'Value', max_off, ...
        'SliderStep', [min(1, row_h / max_off), min(1, max(row_h, h - 2 * pad) / max_off)], ...
        'Position', [w - pad - slider_w, pad, slider_w, max(24, h - 2 * pad)], ...
        'BackgroundColor', theme.color.panel, 'ForegroundColor', theme.color.text, ...
        'Tag', 'zef_shell_flyout_slider', ...
        'Callback', @(s, ~) local_flyout_slider(s, panel));
    try
        sl.BusyAction = 'cancel';
    catch
    end
end
setappdata(h_fig, 'ZefFlyoutPanel', panel);
setappdata(h_fig, 'ZefFlyoutSource', src);
local_remember_source(h_fig, src, level);
if level > 1
    try
        local_mark_open_item(h_fig, src);
    catch
    end
end
uistack(panel, 'top');
try
    local_ensure_flyout_wheel(h_fig);
catch
end

end

function w = local_flyout_width(labels, theme)

w = theme.space.flyoutW;
nch = 0;
for i = 1:numel(labels)
    try
        nch = max(nch, numel(char(string(labels{i}))));
    catch
    end
end
fs = 12;
try
    fs = theme.font.size;
catch
end
need = 52 + round(nch * fs * 0.72);
w = max(w, min(480, need));

end

function label = local_menu_label(h_menu)

label = '';
try
    label = strtrim(char(string(h_menu.Text)));
catch
end
if isempty(label)
    try
        label = strtrim(char(string(h_menu.Label)));
    catch
    end
end
if startsWith(label, 'ZEFFIRO Interface:')
    label = zef_ui_window_label(label);
end

end

function local_leaf_click(src, h_fig)

if local_dup_click(h_fig, src)
    return
end
h_menu = getappdata(src, 'ZefMenuHandle');
local_dismiss(h_fig);
local_invoke_menu(h_menu);

end

function local_sub_click(src, h_fig, level)

if local_dup_click(h_fig, src)
    return
end
open_src = [];
try
    open_src = getappdata(h_fig, 'ZefFlyoutSource');
catch
end
if local_ok(open_src) && isequal(open_src, src)
    local_dismiss_from(h_fig, level);
    return
end
try
    open_items = getappdata(h_fig, 'ZefFlyoutOpenItems');
    if iscell(open_items)
        for i = 1:numel(open_items)
            if isequal(open_items{i}, src)
                local_dismiss_from(h_fig, level);
                return
            end
        end
    end
catch
end
h_menu = getappdata(src, 'ZefMenuHandle');
kids = local_menu_children(h_menu);
if isempty(kids)
    local_dismiss(h_fig);
    local_invoke_menu(h_menu);
    return
end
local_open_flyout(h_fig, src, kids, level);

end

function local_flyout_slider(src, panel)

max_off = [];
try
    max_off = getappdata(panel, 'ZefFlyoutMaxOff');
catch
end
if isempty(max_off)
    try
        max_off = src.Max;
    catch
        max_off = 0;
    end
end
offset = 0;
try
    offset = max_off - src.Value;
catch
end
local_flyout_apply_offset(panel, offset);

end

function local_flyout_apply_offset(panel, offset)

if ~local_ok(panel)
    return
end
items = [];
try
    items = getappdata(panel, 'ZefFlyoutItems');
catch
end
row_h = 28;
pad = 8;
try
    rh = getappdata(panel, 'ZefFlyoutRowH');
    if ~isempty(rh)
        row_h = rh;
    end
    pd = getappdata(panel, 'ZefFlyoutPad');
    if ~isempty(pd)
        pad = pd;
    end
catch
end
ht = [];
try
    panel.Units = 'pixels';
    ht = panel.Position(4);
catch
    return
end
yy = ht - pad - row_h + offset;
for i = 1:numel(items)
    if local_ok(items(i))
        try
            items(i).Position(2) = yy;
        catch
        end
    end
    yy = yy - row_h;
end

end

function local_flyout_nudge(panel, scroll_count)

if ~local_ok(panel) || isempty(scroll_count) || scroll_count == 0
    return
end
sl = findall(panel, 'Tag', 'zef_shell_flyout_slider');
if isempty(sl)
    return
end
sl = sl(1);
row_h = 28;
try
    rh = getappdata(panel, 'ZefFlyoutRowH');
    if ~isempty(rh)
        row_h = rh;
    end
catch
end
try
    newv = sl.Value - double(scroll_count) * row_h;
    sl.Value = min(sl.Max, max(sl.Min, newv));
    local_flyout_slider(sl, panel);
catch
end

end

function local_invoke_menu(h_menu)

if ~local_ok(h_menu)
    return
end
before = [];
try
    before = findall(groot, 'Type', 'figure');
catch
end
fcn = [];
try
    fcn = get(h_menu, 'MenuSelectedFcn');
catch
end
if isempty(fcn)
    try
        fcn = get(h_menu, 'Callback');
    catch
    end
end
try
    if isa(fcn, 'function_handle')
        fcn(h_menu, []);
    elseif iscell(fcn) && ~isempty(fcn) && isa(fcn{1}, 'function_handle')
        fcn{1}(h_menu, [], fcn{2:end});
    elseif (ischar(fcn) || isstring(fcn)) && strlength(strtrim(string(fcn))) > 0
        evalin('base', char(fcn));
    end
catch err
    warning('zef_ui_shell:MenuCallback', '%s', err.message);
end
try
    zef_live = evalin('base', 'zef');
    local_hide_menu(zef_live);
catch
end
try
    drawnow nocallbacks;
catch
end
try
    zef_ui_ready_new_windows();
catch
end
try
    after = findall(groot, 'Type', 'figure');
    spawned = setdiff(after, before);
    for i = 1:numel(spawned)
        try
            vis = 'on';
            if isprop(spawned(i), 'Visible')
                vis = char(spawned(i).Visible);
            end
            if strcmpi(vis, 'on')
                zef_window_manager('raise', spawned(i));
            end
        catch
        end
    end
catch
end

end

function local_dismiss(h_fig)

if nargin < 1 || isempty(h_fig) || ~isgraphics(h_fig) || ~isvalid(h_fig)
    return
end
found = findall(h_fig, '-regexp', 'Tag', '^zef_shell_flyout');
for i = 1:numel(found)
    try
        if isvalid(found(i))
            delete(found(i));
        end
    catch
    end
end
try
    setappdata(h_fig, 'ZefFlyoutSource', []);
    setappdata(h_fig, 'ZefFlyoutPanel', []);
    setappdata(h_fig, 'ZefFlyoutSources', {});
    local_clear_open_items(h_fig);
catch
end

end

function local_dismiss_from(h_fig, min_level)

if nargin < 1 || isempty(h_fig) || ~isgraphics(h_fig) || ~isvalid(h_fig)
    return
end
if nargin < 2 || isempty(min_level)
    min_level = 1;
end
if min_level <= 1
    local_dismiss(h_fig);
    return
end
found = findall(h_fig, '-regexp', 'Tag', '^zef_shell_flyout');
for i = 1:numel(found)
    if ~isvalid(found(i))
        continue
    end
    if local_flyout_level(found(i)) >= min_level
        try
            delete(found(i));
        catch
        end
    end
end
local_trim_open_items(h_fig, max(0, min_level - 2));
local_sync_flyout_state(h_fig);

end

function lv = local_flyout_level(panel)

lv = 1;
try
    tag = char(panel.Tag);
    tok = regexp(tag, 'zef_shell_flyout_(\d+)', 'tokens', 'once');
    if ~isempty(tok)
        lv = str2double(tok{1});
    end
catch
end
if isempty(lv) || isnan(lv)
    lv = 1;
end

end

function tf = local_dup_click(h_fig, src)

tf = false;
if ~local_ok(h_fig)
    return
end
last_src = [];
last_t = [];
try
    last_src = getappdata(h_fig, 'ZefClickSrc');
    last_t = getappdata(h_fig, 'ZefClickTic');
catch
end
try
    setappdata(h_fig, 'ZefClickSrc', src);
    setappdata(h_fig, 'ZefClickTic', tic);
catch
end
if ~isempty(last_t) && ~isempty(last_src) && isequal(last_src, src)
    try
        tf = toc(last_t) < 0.12;
    catch
        tf = false;
    end
end

end

function local_remember_source(h_fig, src, level)

stack = {};
try
    stack = getappdata(h_fig, 'ZefFlyoutSources');
catch
end
if ~iscell(stack)
    stack = {};
end
if level < 1
    level = 1;
end
if numel(stack) >= level
    stack = stack(1:level);
end
stack{level} = src; %#ok<AGROW>
try
    setappdata(h_fig, 'ZefFlyoutSources', stack);
catch
end

end

function local_sync_flyout_state(h_fig)

found = findall(h_fig, '-regexp', 'Tag', '^zef_shell_flyout');
if isempty(found)
    try
        setappdata(h_fig, 'ZefFlyoutSource', []);
        setappdata(h_fig, 'ZefFlyoutPanel', []);
        setappdata(h_fig, 'ZefFlyoutSources', {});
    catch
    end
    local_clear_open_items(h_fig);
    return
end
keep = found(1);
keep_lv = 0;
for i = 1:numel(found)
    lv = local_flyout_level(found(i));
    if lv >= keep_lv
        keep_lv = lv;
        keep = found(i);
    end
end
try
    setappdata(h_fig, 'ZefFlyoutPanel', keep);
catch
end
stack = {};
try
    stack = getappdata(h_fig, 'ZefFlyoutSources');
catch
end
src = [];
if iscell(stack) && keep_lv >= 1 && keep_lv <= numel(stack)
    src = stack{keep_lv};
end
try
    setappdata(h_fig, 'ZefFlyoutSource', src);
    if iscell(stack) && numel(stack) > keep_lv
        setappdata(h_fig, 'ZefFlyoutSources', stack(1:keep_lv));
    end
catch
end

end

function local_mark_open_item(h_fig, src)

if ~local_ok(src)
    return
end
open = {};
try
    open = getappdata(h_fig, 'ZefFlyoutOpenItems');
catch
end
if ~iscell(open)
    open = {};
end
keep = {};
for i = 1:numel(open)
    if local_ok(open{i}) && ~isequal(open{i}, src)
        keep{end+1} = open{i}; %#ok<AGROW>
    end
end
keep{end+1} = src; %#ok<AGROW>
try
    setappdata(h_fig, 'ZefFlyoutOpenItems', keep);
catch
end
try
    theme = zef_ui_theme();
    src.BackgroundColor = theme.color.hover;
catch
end

end

function local_trim_open_items(h_fig, keep_n)

open = {};
try
    open = getappdata(h_fig, 'ZefFlyoutOpenItems');
catch
end
if ~iscell(open)
    open = {};
end
if nargin < 2 || isempty(keep_n)
    keep_n = 0;
end
keep_n = max(0, keep_n);
keep = {};
for i = 1:numel(open)
    if i > keep_n
        try
            if local_ok(open{i})
                theme = zef_ui_theme();
                open{i}.BackgroundColor = theme.color.panel;
            end
        catch
        end
    elseif local_ok(open{i})
        keep{end+1} = open{i}; %#ok<AGROW>
    end
end
try
    setappdata(h_fig, 'ZefFlyoutOpenItems', keep);
catch
end

end

function local_clear_open_items(h_fig)

open = {};
try
    open = getappdata(h_fig, 'ZefFlyoutOpenItems');
catch
end
if iscell(open)
    theme = [];
    try
        theme = zef_ui_theme();
    catch
    end
    for i = 1:numel(open)
        try
            if local_ok(open{i}) && ~isempty(theme)
                open{i}.BackgroundColor = theme.color.panel;
            end
        catch
        end
    end
end
try
    setappdata(h_fig, 'ZefFlyoutOpenItems', {});
catch
end

end

function local_dismiss_top(h_fig)

if nargin < 1 || isempty(h_fig) || ~isgraphics(h_fig) || ~isvalid(h_fig)
    return
end
found = findall(h_fig, '-regexp', 'Tag', '^zef_shell_flyout');
if isempty(found)
    local_dismiss(h_fig);
    return
end
max_lv = 1;
for i = 1:numel(found)
    max_lv = max(max_lv, local_flyout_level(found(i)));
end
local_dismiss_from(h_fig, max_lv);

end

function local_window_down(src, evt)

h_fig = ancestor(src, 'figure');
if isempty(h_fig)
    h_fig = src;
end
obj = [];
try
    obj = hittest(h_fig);
catch
    try
        obj = h_fig.CurrentObject;
    catch
    end
end
keep = false;
try
    if ~isempty(obj) && isgraphics(obj)
        tag = '';
        try
            tag = char(obj.Tag);
        catch
        end
        keep = strncmp(tag, 'zef_nav_', 8) || contains(tag, 'zef_shell_flyout') ...
            || strncmp(tag, 'zef_shell_theme', 15);
        try
            open_src = getappdata(h_fig, 'ZefFlyoutSource');
            if local_ok(open_src)
                h = obj;
                for n = 1:6
                    if ~local_ok(h)
                        break
                    end
                    if isequal(h, open_src)
                        keep = true;
                        break
                    end
                    h = h.Parent;
                end
            end
        catch
        end
        par = obj;
        for k = 1:8
            if keep || isempty(par)
                break
            end
            try
                ptag = char(par.Tag);
            catch
                ptag = '';
            end
            if contains(ptag, 'zef_shell_flyout') || strncmp(ptag, 'zef_nav_', 8) ...
                    || strncmp(ptag, 'zef_nav_icon_', 13) || strncmp(ptag, 'zef_nav_row_', 12) ...
                    || strncmp(ptag, 'zef_nav_hit_', 12)
                keep = true;
                break
            end
            par = par.Parent;
        end
    end
catch
end
if ~keep
    local_dismiss(h_fig);
end
prev = [];
try
    prev = getappdata(h_fig, 'ZefShellPrevDownFcn');
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

function local_window_key(src, evt)

h_fig = ancestor(src, 'figure');
if isempty(h_fig)
    h_fig = src;
end
consumed = false;
try
    key = '';
    if isstruct(evt) && isfield(evt, 'Key')
        key = char(evt.Key);
    end
    if strcmpi(key, 'escape')
        fly = findall(h_fig, '-regexp', 'Tag', '^zef_shell_flyout');
        if ~isempty(fly)
            local_dismiss_top(h_fig);
            consumed = true;
        end
    end
catch
end
if consumed
    return
end
prev = [];
try
    prev = getappdata(h_fig, 'ZefShellPrevKeyFcn');
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

function local_ensure_flyout_wheel(h_fig)

if ~local_ok(h_fig)
    return
end
cur = [];
try
    cur = get(h_fig, 'WindowScrollWheelFcn');
catch
end
our = [];
try
    our = getappdata(h_fig, 'ZefFlyoutWheelFcn');
catch
end
if ~isempty(our) && isequal(cur, our)
    return
end
try
    setappdata(h_fig, 'ZefShellPrevWheelFcn', cur);
catch
end
wrapper = @(src, evt) local_flyout_wheel(src, evt);
try
    setappdata(h_fig, 'ZefFlyoutWheelFcn', wrapper);
    h_fig.WindowScrollWheelFcn = wrapper;
catch
end

end

function local_flyout_wheel(src, evt)

h_fig = ancestor(src, 'figure');
if isempty(h_fig)
    h_fig = src;
end
consumed = false;
obj = [];
try
    obj = hittest(h_fig);
catch
end
n = 0;
try
    n = evt.VerticalScrollCount;
catch
end
try
    fly = [];
    if isappdata(h_fig, 'ZefFlyoutPanel')
        fly = getappdata(h_fig, 'ZefFlyoutPanel');
    end
    if local_ok(fly)
        hit_panel = local_flyout_panel_of(obj);
        if ~local_ok(hit_panel)
            hit_panel = fly;
            if ~local_over_flyout(obj)
                hit_panel = [];
            end
        end
        if local_ok(hit_panel)
            if ~isempty(n) && n ~= 0
                local_flyout_nudge(hit_panel, n);
            end
            consumed = true;
        end
    end
catch
end
if ~consumed
    try
        consumed = local_chrome_wheel(obj, n);
    catch
        consumed = false;
    end
end
if consumed
    return
end
prev = [];
try
    prev = getappdata(h_fig, 'ZefShellPrevWheelFcn');
catch
end
try
    if isa(prev, 'function_handle')
        prev(src, evt);
    elseif iscell(prev) && ~isempty(prev) && isa(prev{1}, 'function_handle')
        prev{1}(src, evt, prev{2:end});
    elseif (ischar(prev) || isstring(prev)) && strlength(prev) > 0
        evalin('base', char(prev));
    end
catch
end

end

function tf = local_chrome_wheel(obj, scroll_count)

tf = false;
if ~local_ok(obj) || local_is_plot_hit(obj) || ~local_is_chrome_hit(obj)
    return
end
tf = true;
if isempty(scroll_count) || scroll_count == 0
    return
end
style = '';
try
    if strcmpi(char(obj.Type), 'uicontrol')
        style = lower(char(obj.Style));
    end
catch
end
if strcmp(style, 'slider')
    local_nudge_uicontrol_slider(obj, scroll_count);
elseif strcmp(style, 'listbox')
    local_nudge_listbox(obj, scroll_count);
end

end

function tf = local_is_plot_hit(obj)

tf = false;
h = obj;
for k = 1:8
    if ~local_ok(h)
        return
    end
    typ = '';
    try
        typ = lower(char(h.Type));
    catch
    end
    if any(strcmp(typ, {'axes', 'uiaxes'}))
        tf = true;
        return
    end
    try
        h = h.Parent;
    catch
        return
    end
end

end

function tf = local_is_chrome_hit(obj)

tf = false;
h = obj;
chrome = {'figure_sidebar', 'figure_lists', 'zef_shell_nav', 'zef_shell_header', ...
    'zef_shell_toolbar', 'zef_shell_tabs', 'zef_shell_footer', 'zef_shell_flyout'};
for k = 1:10
    if ~local_ok(h)
        return
    end
    tag = '';
    try
        tag = char(h.Tag);
    catch
    end
    for i = 1:numel(chrome)
        if strcmp(tag, chrome{i}) || strncmp(tag, [chrome{i} '_'], numel(chrome{i}) + 1)
            tf = true;
            return
        end
    end
    if contains(tag, 'zef_shell_flyout')
        tf = true;
        return
    end
    try
        h = h.Parent;
    catch
        return
    end
end

end

function local_nudge_uicontrol_slider(sl, scroll_count)

if ~local_ok(sl)
    return
end
tag = '';
try
    tag = char(sl.Tag);
catch
end
% Time slider Callback visualizes reconstructions; only block camera zoom.
if strcmp(tag, 'slider')
    return
end
mn = 0;
mx = 1;
v = 0;
try
    mn = sl.Min;
    mx = sl.Max;
    v = sl.Value;
catch
    return
end
range = mx - mn;
if ~isfinite(range) || range <= 0
    return
end
step = range * 0.02;
try
    ss = sl.SliderStep;
    if ~isempty(ss)
        step = max(step, ss(1) * range);
    end
catch
end
try
    sl.Value = min(mx, max(mn, v - double(scroll_count) * step));
catch
    return
end
cb = [];
try
    cb = sl.Callback;
catch
end
try
    if isa(cb, 'function_handle')
        cb(sl, []);
    elseif (ischar(cb) || isstring(cb)) && strlength(cb) > 0
        evalin('base', char(cb));
    end
catch
end

end

function local_nudge_listbox(lb, scroll_count)

if ~local_ok(lb)
    return
end
n = 0;
try
    n = numel(lb.String);
catch
end
if n < 2
    return
end
top = 1;
try
    top = lb.ListboxTop;
catch
end
try
    lb.ListboxTop = min(n, max(1, top + double(scroll_count)));
catch
end

end

function tf = local_over_flyout(obj)

tf = local_ok(local_flyout_panel_of(obj));

end

function p = local_flyout_panel_of(obj)

p = [];
h = obj;
for k = 1:10
    if ~local_ok(h)
        return
    end
    try
        tag = char(h.Tag);
        if strcmpi(char(h.Type), 'uipanel') && contains(tag, 'zef_shell_flyout')
            p = h;
            return
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

function local_theme(h_fig)

if nargin < 1 || isempty(h_fig) || ~isgraphics(h_fig) || ~isvalid(h_fig)
    return
end
theme = zef_ui_theme();
try
    h_fig.Color = theme.color.bg;
catch
end
tags = {'zef_shell_header', 'zef_shell_nav', 'zef_shell_tabs', ...
    'zef_shell_toolbar', 'zef_shell_footer'};
bgs = {theme.color.headerBg, theme.color.bg, theme.color.workspace, ...
    theme.color.workspace, theme.color.footerBg};
for i = 1:numel(tags)
    p = zef_ui_find(h_fig, tags{i});
    if local_ok(p)
        try
            p.BackgroundColor = bgs{i};
            p.HighlightColor = theme.color.border;
        catch
        end
    end
end
zef_ui_apply_theme(h_fig, theme);
try
    zef_figure_tool_layout(h_fig);
catch
    local_layout(h_fig);
end

end

function local_theme_pill(src, ~)

h_fig = [];
try
    h_fig = ancestor(src, 'figure');
catch
end
if ~local_ok(h_fig)
    return
end
anchor = zef_ui_find(h_fig, 'zef_shell_theme_pill');
if ~local_ok(anchor)
    anchor = src;
end
open_src = [];
try
    open_src = getappdata(h_fig, 'ZefFlyoutSource');
catch
end
if local_ok(open_src) && isequal(open_src, anchor)
    local_dismiss(h_fig);
    return
end
cm = [];
try
    cm = getappdata(h_fig, 'ZefThemeMenu');
catch
end
if isempty(cm) || ~isvalid(cm)
    cm = uicontextmenu('Parent', h_fig);
    uimenu(cm, 'Text', 'Light', 'Callback', @(~, ~) local_pick_theme(h_fig, 1));
    uimenu(cm, 'Text', 'Dark', 'Callback', @(~, ~) local_pick_theme(h_fig, 2));
    setappdata(h_fig, 'ZefThemeMenu', cm);
end
local_open_flyout(h_fig, anchor, local_menu_children(cm), 1);

end

function local_pick_theme(h_fig, val)

pop = zef_ui_find(h_fig, 'zef_shell_theme');
local_dismiss(h_fig);
if ~local_ok(pop)
    return
end
try
    pop.Value = val;
catch
end
local_theme_changed(pop);

end

function local_theme_changed(src, ~)

val = 1;
try
    val = src.Value;
catch
end
mode = 'light';
if val >= 2
    mode = 'dark';
end
try
    zef = evalin('base', 'zef');
    zef.ui_color_mode = mode;
    assignin('base', 'zef', zef);
catch
end
h_fig = ancestor(src, 'figure');
try
    zef_ui_broadcast_theme();
catch
    local_theme(h_fig);
end

end

function local_clear_tools(h_fig)

keys = {'pan', 'rotate', 'zoom', 'measure', 'annotate'};
for i = 1:numel(keys)
    b = zef_ui_find(h_fig, ['zef_tool_' keys{i}]);
    if local_ok(b)
        b.UserData = 0;
        try
            b.Value = 0;
        catch
        end
    end
end
ax = zef_ui_axes(h_fig);
if isempty(ax) || ~isvalid(ax)
    try
        datacursormode(h_fig, 'off');
    catch
    end
    try
        plotedit(h_fig, 'off');
    catch
    end
    return
end
try
    pan(ax, 'off');
catch
end
try
    rotate3d(ax, 'off');
catch
end
try
    zoom(ax, 'off');
catch
end
try
    datacursormode(h_fig, 'off');
catch
end
try
    plotedit(h_fig, 'off');
catch
end

end

function local_tool_pan(src, ~)

src = local_tool_src(src, 'pan');
h_fig = ancestor(src, 'figure');
on = ~isequal(src.UserData, 1);
local_clear_tools(h_fig);
src.UserData = double(on);
if ~isempty(h_fig) && isvalid(h_fig)
    ax = zef_ui_axes(h_fig);
    if ~isempty(ax) && isvalid(ax)
        try
            pan(ax, onoff(on));
        catch
        end
    end
end
try
    local_refresh_toolbar(h_fig);
catch
end

end

function local_tool_rotate(src, ~)

src = local_tool_src(src, 'rotate');
h_fig = ancestor(src, 'figure');
on = ~isequal(src.UserData, 1);
local_clear_tools(h_fig);
src.UserData = double(on);
if ~isempty(h_fig) && isvalid(h_fig)
    ax = zef_ui_axes(h_fig);
    if ~isempty(ax) && isvalid(ax)
        try
            rotate3d(ax, onoff(on));
        catch
        end
    end
end
try
    local_refresh_toolbar(h_fig);
catch
end

end

function local_tool_zoom(src, ~)

src = local_tool_src(src, 'zoom');
h_fig = ancestor(src, 'figure');
on = ~isequal(src.UserData, 1);
local_clear_tools(h_fig);
src.UserData = double(on);
if ~isempty(h_fig) && isvalid(h_fig)
    ax = zef_ui_axes(h_fig);
    if ~isempty(ax) && isvalid(ax)
        try
            zoom(ax, onoff(on));
        catch
        end
    end
end
try
    local_refresh_toolbar(h_fig);
catch
end

end

function local_tool_reset(src, ~)

h_fig = [];
try
    h_fig = ancestor(src, 'figure');
catch
end
if isempty(h_fig) || ~isvalid(h_fig)
    h_fig = gcbf;
end
if isempty(h_fig) || ~isvalid(h_fig)
    try
        h_fig = evalin('base', 'zef.h_zeffiro');
    catch
        h_fig = [];
    end
end
ax = zef_ui_axes(h_fig);
if isempty(ax) || ~isvalid(ax)
    return
end
try
    local_clear_tools(h_fig);
    local_refresh_toolbar(h_fig);
catch
end
try
    view(ax, 3);
    axis(ax, 'vis3d');
    axis(ax, 'tight');
catch
end

end

function local_tool_screenshot(~, ~)

try
    evalin('base', 'zef.save_switch=10; zef_save; zef = zef_update(zef);');
catch
end

end

function local_tool_colormap(src, ~)

h_fig = ancestor(src, 'figure');
open_src = [];
try
    open_src = getappdata(h_fig, 'ZefFlyoutSource');
catch
end
if local_ok(open_src) && isequal(open_src, src)
    local_dismiss(h_fig);
    return
end
pop = zef_ui_find(h_fig, 'colormapselection');
if ~local_ok(pop)
    return
end
items = {};
try
    items = cellstr(string(pop.String));
catch
end
if isempty(items)
    return
end
cm = uicontextmenu(h_fig);
for i = 1:numel(items)
    uimenu(cm, 'Text', items{i}, 'Callback', @(~, ~) local_set_colormap(pop, i, h_fig));
end
local_open_flyout(h_fig, src, local_menu_children(cm), 1);

end

function local_set_colormap(pop, idx, h_fig)

try
    local_dismiss(h_fig);
catch
end
pop.Value = idx;
try
    cb = pop.Callback;
    if isa(cb, 'function_handle')
        cb(pop, []);
    elseif (ischar(cb) || isstring(cb)) && strlength(cb) > 0
        evalin('base', char(cb));
    end
catch
end
try
        evalin('base', 'zef.update_colormap = zef.h_update_colormap.Value; zef_update_contrast_and_brightness(zef.h_zeffiro);');
catch
end

end

function local_tool_edges(~, ~)

try
    zef_toggle_edges;
catch
end

end

function local_tool_measure(src, ~)

src = local_tool_src(src, 'measure');
h_fig = ancestor(src, 'figure');
on = ~isequal(src.UserData, 1);
local_clear_tools(h_fig);
src.UserData = double(on);
try
    datacursormode(h_fig, onoff(on));
catch
end
try
    local_refresh_toolbar(h_fig);
catch
end

end

function local_tool_annotate(src, ~)

src = local_tool_src(src, 'annotate');
h_fig = ancestor(src, 'figure');
on = ~isequal(src.UserData, 1);
local_clear_tools(h_fig);
src.UserData = double(on);
try
    plotedit(h_fig, onoff(on));
catch
end
try
    local_refresh_toolbar(h_fig);
catch
end

end

function local_open_log(~, ~)

p = '';
try
    zef = evalin('base', 'zef');
    if isstruct(zef) && isfield(zef, 'program_path')
        p = fullfile(zef.program_path, 'data', 'log');
    end
catch
end
if isempty(p) || ~isfolder(p)
    p = fullfile(pwd, 'data', 'log');
end
try
    if ismac
        system(sprintf('open "%s"', p));
    elseif ispc
        winopen(p);
    else
        system(sprintf('xdg-open "%s"', p));
    end
catch
end

end

function local_open_profile(~, ~)

try
    evalin('base', 'zef_open_init_profile;');
catch
end

end

function local_tool_more(~, h_fig)

ax = zef_ui_axes(h_fig);
if isempty(ax) || ~isvalid(ax)
    return
end
try
    figure(h_fig);
catch
end
try
    zef_axes_popup;
catch
end

end

function local_raise_figure()

zef = [];
try
    zef = evalin('base', 'zef');
catch
end
if isstruct(zef) && isfield(zef, 'h_zeffiro') && local_ok(zef.h_zeffiro)
    zef_window_manager('raise', zef.h_zeffiro);
    return
end
try
    zef_figure_tool;
catch
end

end

function local_tool_from_label(src, key)

h_fig = ancestor(src, 'figure');
if isempty(h_fig) || ~isvalid(h_fig)
    return
end
btn = zef_ui_find(h_fig, ['zef_tool_' key]);
if ~local_ok(btn)
    return
end
try
    cb = btn.Callback;
    if isa(cb, 'function_handle')
        cb(btn, []);
    end
catch
end

end

function src = local_tool_src(src, key)

src = local_hit_src(src);
if ~local_ok(src)
    return
end
try
    tag = char(src.Tag);
    if startsWith(tag, 'zef_tool_lab_')
        h_fig = ancestor(src, 'figure');
        btn = zef_ui_find(h_fig, ['zef_tool_' key]);
        if local_ok(btn)
            src = btn;
        end
    end
catch
end

end

function inset = local_right_inset(h_fig)

inset = 0;
try
    v = getappdata(h_fig, 'ZefShellRightInset');
    if ~isempty(v)
        inset = max(0, double(v(1)));
    end
catch
end

end

function local_raise_chrome(h_fig)

view = zef_ui_find(h_fig, 'figure_view');
if local_ok(view)
    try
        uistack(view, 'top');
    catch
    end
else
    ax = zef_ui_find(h_fig, 'axes1');
    if local_ok(ax)
        try
            uistack(ax, 'top');
        catch
        end
    end
end
tt = zef_ui_find(h_fig, 'time_text');
if local_ok(tt)
    try
        uistack(tt, 'top');
    catch
    end
end
order = {'figure_lists', 'figure_sidebar', 'zef_shell_tabs', ...
    'zef_shell_toolbar', 'zef_shell_header', 'zef_shell_nav', 'zef_shell_footer'};
for i = 1:numel(order)
    h = zef_ui_find(h_fig, order{i});
    if local_ok(h)
        try
            uistack(h, 'top');
        catch
        end
    end
end
found = findall(h_fig, '-regexp', 'Tag', '^zef_shell_flyout');
for i = 1:numel(found)
    if local_ok(found(i))
        try
            uistack(found(i), 'top');
        catch
        end
    end
end

end

function label = local_tool_label(key)

labels = struct('pan', 'Pan', 'rotate', 'Rotate', 'zoom', 'Zoom', ...
    'reset', 'Reset View', 'screenshot', 'Screenshot', ...
    'colormap', 'Colormap', 'measure', 'Measure', 'annotate', 'Annotate', ...
    'edges', 'Toggle Edges');
label = key;
try
    label = labels.(key);
catch
end

end

function h = local_make_icon_btn(parent, tag, bg, hittable)

h = uicontrol('Style', 'pushbutton', 'Parent', parent, 'Units', 'pixels', ...
    'String', '', 'Tag', tag, 'BackgroundColor', bg, 'ForegroundColor', bg);
if hittable
    h.Callback = @local_nav_click;
    try
        h.BusyAction = 'cancel';
    catch
    end
else
    h.Enable = 'inactive';
end

end

function local_show_icon(h, name, sz, fg, bg)

if ~local_ok(h)
    return
end
bw = sz;
bh = sz;
try
    u = h.Units;
    h.Units = 'pixels';
    bw = max(sz, round(h.Position(3)));
    bh = max(sz, round(h.Position(4)));
    h.Units = u;
catch
end
key = {char(name), sz, bw, bh, round(double(fg(1:min(3, numel(fg)))) * 1000), ...
    round(double(bg(1:min(3, numel(bg)))) * 1000)};
try
    prev = getappdata(h, 'ZefIconKey');
    if isequal(prev, key) && ~isempty(h.CData)
        return
    end
catch
end
cdata = [];
try
    cdata = zef_ui_icons(name, sz, fg, bg);
catch
end
try
    h.String = '';
    h.BackgroundColor = bg;
    if ~isempty(cdata)
        try
            full = repmat(reshape(double(bg(1:3)), 1, 1, 3), bh, bw);
            ih = size(cdata, 1);
            iw = size(cdata, 2);
            r0 = max(1, floor((bh - ih) / 2) + 1);
            c0 = max(1, floor((bw - iw) / 2) + 1);
            r1 = min(bh, r0 + ih - 1);
            c1 = min(bw, c0 + iw - 1);
            full(r0:r1, c0:c1, :) = cdata(1:(r1 - r0 + 1), 1:(c1 - c0 + 1), :);
            h.CData = full;
        catch
            h.CData = cdata;
        end
    end
    setappdata(h, 'ZefIconKey', key);
catch
end

end

function src = local_hit_src(src)

try
    if strcmpi(char(src.Type), 'image') && ~isempty(src.Parent)
        src = src.Parent;
    end
catch
end

end

function local_restore_axes(h_fig)

ax = zef_ui_find(h_fig, 'axes1');
if local_ok(ax)
    try
        set(h_fig, 'CurrentAxes', ax);
    catch
    end
end

end

function tf = local_ok(h)

tf = false;
try
    tf = ~isempty(h) && isgraphics(h) && isvalid(h);
catch
end

end

function s = onoff(tf)

if tf
    s = 'on';
else
    s = 'off';
end

end
