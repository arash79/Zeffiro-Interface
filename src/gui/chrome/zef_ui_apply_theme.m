function zef_ui_apply_theme(h, theme)
%ZEF_UI_APPLY_THEME  Paint a figure and its controls with the shared theme.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Walks findall(h) and sets Color / Font / Background on widgets that
%   expose those properties. Axes, images, colorbars, legends, and uihtml
%   lists are left alone so plots and color-swatch lists keep their data.
%
%   zef_ui_apply_theme(h)
%   zef_ui_apply_theme(h, theme)
%
%   See also zef_ui_theme, zef_ui_ready, zef_ui_blend_logo.

if nargin < 1 || isempty(h) || ~isgraphics(h) || ~isvalid(h)
    return
end
if nargin < 2 || isempty(theme)
    theme = zef_ui_theme();
end

local_style_figure(h, theme);

kids = findall(h);
for i = 1:numel(kids)
    obj = kids(i);
    if isempty(obj) || ~isvalid(obj) || obj == h
        continue
    end
    try
        local_style_object(obj, theme);
    catch
    end
end

end

function local_style_figure(h, theme)

try
    if isprop(h, 'Color')
        h.Color = theme.color.bg;
    end
catch
end
try
    if isappdata(h, 'ZefUnifiedShell') && isequal(getappdata(h, 'ZefUnifiedShell'), true)
        return
    end
catch
end
try
    if isprop(h, 'Icon')
        icon_file = which('zeffiro_interface_compass.png');
        if isempty(icon_file)
            icon_file = which('zeffiro_logo_compass.png');
        end
        if isempty(icon_file)
            icon_file = which('zeffiro_small_logo.png');
        end
        if ~isempty(icon_file)
            h.Icon = icon_file;
        end
    end
catch
end

end

function local_style_object(obj, theme)

typ = '';
try
    typ = lower(char(obj.Type));
catch
end
tag = '';
try
    tag = char(obj.Tag);
catch
end
if strcmp(tag, 'zef_card_bg') || strcmp(tag, 'zef_shell_card') ...
        || strcmp(tag, 'zef_card_img') || strncmp(tag, 'zef_card_c_', 11) ...
        || strncmp(tag, 'zef_nav_fill_', 13) || strcmp(tag, 'zef_flyout_fill')
    if strcmp(tag, 'zef_shell_card')
        local_set(obj, 'BackgroundColor', theme.color.bg);
    end
    return
end

switch typ
    case {'legend', 'colorbar', 'image', 'light', 'surface', ...
            'patch', 'line', 'text', 'uihtml', 'webprovider'}
        return
    case {'axes', 'uiaxes'}
        local_style_axes(obj, theme);
        return
    case {'uiimage'}
        try
            obj.ScaleMethod = 'fit';
            obj.BackgroundColor = theme.color.bg;
            obj.VerticalAlignment = 'center';
            tag = '';
            try
                tag = lower(char(obj.Tag));
            catch
            end
            if ~(contains(tag, 'logo') || strcmp(tag, 'h_axes2'))
                obj.HorizontalAlignment = 'center';
            end
        catch
        end
        try
            zef_ui_blend_logo(obj, theme);
        catch
        end
        return
    case {'uigridlayout'}
        try
            par = obj.Parent;
            is_root = strcmp(char(obj.Tag), 'zef_ui_root');
            try
                is_root = is_root || strcmpi(char(par.Type), 'figure');
            catch
            end
            if is_root
                obj.BackgroundColor = theme.color.bg;
            else
                obj.BackgroundColor = theme.color.panel;
            end
        catch
        end
        return
    case {'uipanel', 'panel'}
        bg = theme.color.panel;
        try
            tag = char(obj.Tag);
            if strcmp(tag, 'zef_shell_nav') || strcmp(tag, 'zef_shell_card') ...
                    || strcmp(tag, 'figure_sidebar') || strcmp(tag, 'figure_lists')
                bg = theme.color.bg;
            elseif strncmp(tag, 'zef_nav_row_', 12) || strcmp(tag, 'zef_fly_item')
                bg = theme.color.panel;
            elseif strcmp(tag, 'zef_shell_header')
                bg = theme.color.headerBg;
            elseif strcmp(tag, 'zef_shell_footer')
                bg = theme.color.footerBg;
            elseif strcmp(tag, 'zef_shell_tabs') || strcmp(tag, 'zef_shell_toolbar')
                bg = theme.color.workspace;
            end
        catch
        end
        local_set(obj, 'BackgroundColor', bg);
        local_set(obj, 'ForegroundColor', theme.color.text);
        is_nav_row = false;
        try
            is_nav_row = strncmp(char(obj.Tag), 'zef_nav_row_', 12) ...
                || strcmp(char(obj.Tag), 'zef_fly_item');
        catch
        end
        if is_nav_row
            local_set(obj, 'HighlightColor', bg);
            local_set(obj, 'BorderType', 'none');
        else
            local_set(obj, 'HighlightColor', theme.color.border);
            local_set(obj, 'BorderColor', theme.color.border);
            try
                if strcmpi(char(obj.BorderType), 'none')
                    local_set(obj, 'BorderColor', bg);
                    local_set(obj, 'HighlightColor', bg);
                end
            catch
            end
        end
        local_set(obj, 'FontName', theme.font.name);
        local_set(obj, 'FontSize', theme.font.sizeSmall);
        local_set(obj, 'FontWeight', 'bold');
        try
            ptag = char(obj.Tag);
            if ~strncmp(ptag, 'zef_shell_', 10) && ~strcmp(ptag, 'zef_card_bg') ...
                    && ~strncmp(ptag, 'zef_card_', 9) && ~strncmp(ptag, 'zef_nav_row_', 12) ...
                    && ~strcmp(ptag, 'zef_fly_item')
                local_try_radius(obj, theme, theme.space.cardRadius);
            end
        catch
        end
        return
    case {'uibuttongroup'}
        local_set(obj, 'BackgroundColor', theme.color.panel);
        local_set(obj, 'ForegroundColor', theme.color.text);
        return
end

cls = class(obj);

if contains(cls, 'Button') && ~contains(cls, 'ButtonGroup')
    local_style_button(obj, theme);
    return
end
if contains(cls, 'Label') || strcmp(typ, 'uilabel')
    local_style_label(obj, theme);
    return
end
if contains(cls, 'CheckBox')
    local_style_checkbox(obj, theme);
    return
end
if contains(cls, 'DropDown') || contains(cls, 'ListBox')
    local_style_input(obj, theme);
    return
end
if contains(cls, 'EditField') || contains(cls, 'TextArea') || contains(cls, 'Spinner')
    local_style_input(obj, theme);
    return
end
if contains(cls, 'Table')
    local_style_table(obj, theme);
    return
end
if strcmp(typ, 'uitree') || (contains(cls, 'container.Tree') && ~contains(cls, 'Node'))
    local_style_tree(obj, theme);
    return
end
if contains(cls, 'Slider') && ~strcmp(typ, 'uicontrol')
    local_set(obj, 'FontName', theme.font.name);
    local_set(obj, 'FontSize', theme.font.sizeSmall);
    local_set(obj, 'FontColor', theme.color.text);
    return
end

if strcmp(typ, 'uicontrol')
    local_style_uicontrol(obj, theme);
end

end

function local_style_button(obj, theme)

is_primary = false;
try
    txt = '';
    if isprop(obj, 'Text')
        txt = obj.Text;
    elseif isprop(obj, 'String')
        txt = obj.String;
    end
    txt = regexprep(strtrim(char(join(string(txt), ' '))), '\s+', ' ');
    is_primary = any(strcmpi(txt, { ...
        'Visualize volume', 'Create FEM mesh', 'Plot graph', 'Play', ...
        'Run script', 'Apply', 'Save', 'Plot', 'Start', 'Run', 'Start inversion', ...
        'Find currents', 'Interpolate', 'Plot hyperprior', ...
        'Plot processed data', 'Combine data/leadfields', 'Combine', ...
        'Plot signal', 'Simulate measurements', 'Plot source', ...
        'Apply transformation', 'Compute lead fields', 'Apply to Mesh', ...
        'Create synthetic data', 'Plot source(s)', 'Create wireframe', ...
        'Plot wireframe', 'Solve system'})) ...
        || (contains(lower(txt), 'create') && contains(lower(txt), 'fem')) ...
        || strcmp(char(obj.Tag), 'zef_about_close') ...
        || strcmp(char(obj.Tag), 'zef_confirm_yes');
    if strcmp(char(obj.Tag), 'playbutton')
        is_primary = true;
    end
    try
        if isappdata(obj, 'ZefPrimary') && isequal(getappdata(obj, 'ZefPrimary'), true)
            is_primary = true;
        end
    catch
    end
catch
end
try
    if isappdata(obj, 'ZefRoundKey')
        return
    end
catch
end

if is_primary
    local_set(obj, 'BackgroundColor', theme.color.primary);
    local_set(obj, 'FontColor', theme.color.primaryText);
    local_set(obj, 'ForegroundColor', theme.color.primaryText);
else
    local_set(obj, 'BackgroundColor', theme.color.button);
    local_set(obj, 'FontColor', theme.color.buttonText);
    local_set(obj, 'ForegroundColor', theme.color.buttonText);
end
try
    if strcmpi(char(obj.Enable), 'off')
        local_set(obj, 'FontColor', theme.color.disabled);
        local_set(obj, 'ForegroundColor', theme.color.disabled);
    end
catch
end
local_set(obj, 'FontName', theme.font.name);
local_set(obj, 'FontSize', theme.font.size);
local_set(obj, 'FontWeight', 'normal');
local_try_radius(obj, theme);

end

function local_style_label(obj, theme)

local_set(obj, 'FontName', theme.font.name);
keep_small = false;
try
    cur = double(obj.FontSize);
    keep_small = cur > 0 && cur <= 10;
catch
end
if keep_small
    local_set(obj, 'FontColor', theme.color.textMuted);
else
    local_set(obj, 'FontSize', theme.font.size);
    local_set(obj, 'FontColor', theme.color.text);
end
local_set(obj, 'BackgroundColor', 'none');
try
    if isprop(obj, 'Interpreter')
        obj.Interpreter = 'none';
    end
catch
end

end

function local_style_checkbox(obj, theme)

local_set(obj, 'FontName', theme.font.name);
local_set(obj, 'FontSize', theme.font.size);
local_set(obj, 'FontColor', theme.color.text);
local_set(obj, 'FontWeight', 'normal');
try
    if isprop(obj, 'BackgroundColor') && ~ischar(obj.BackgroundColor) ...
            && ~isstring(obj.BackgroundColor)
        obj.BackgroundColor = theme.color.panel;
    end
catch
end

end

function local_style_input(obj, theme)

local_set(obj, 'FontName', theme.font.name);
local_set(obj, 'FontSize', theme.font.size);
local_set(obj, 'FontColor', theme.color.text);
local_set(obj, 'BackgroundColor', theme.color.inputBg);
local_set(obj, 'ForegroundColor', theme.color.text);
local_try_radius(obj, theme, 4);

end

function local_style_table(obj, theme)

local_set(obj, 'FontName', theme.font.name);
local_set(obj, 'FontSize', theme.font.size);
local_set(obj, 'FontColor', theme.color.text);
local_set(obj, 'ForegroundColor', theme.color.text);
try
    obj.RowStriping = 'on';
    obj.BackgroundColor = [theme.color.tableRow; theme.color.tableAlt];
catch
    local_set(obj, 'BackgroundColor', theme.color.tableRow);
end
try
    obj.RowHeight = theme.space.tableRow;
catch
end
try
    removeStyle(obj);
catch
end
try
    st = uistyle('FontColor', theme.color.text, ...
        'BackgroundColor', theme.color.tableRow, ...
        'FontName', theme.font.name, 'FontSize', theme.font.size, ...
        'HorizontalAlignment', 'left');
    addStyle(obj, st);
catch
    try
        st = uistyle('FontColor', theme.color.text, ...
            'FontName', theme.font.name, 'FontSize', theme.font.size, ...
            'HorizontalAlignment', 'left');
        addStyle(obj, st);
    catch
    end
end
try
    hst = uistyle('BackgroundColor', theme.color.tableHeader, ...
        'FontColor', theme.color.text, 'FontWeight', 'bold');
    n_col = 1;
    try
        n_col = max(1, numel(obj.ColumnName));
    catch
    end
    addStyle(obj, hst, 'header', 1:n_col);
catch
    try
        addStyle(obj, hst, 'header');
    catch
    end
end
zef_ui_fit_table(obj);

end

function local_style_tree(obj, theme)

local_set(obj, 'FontName', theme.font.name);
local_set(obj, 'FontSize', theme.font.size);
local_set(obj, 'FontColor', theme.color.text);
local_set(obj, 'ForegroundColor', theme.color.text);
local_set(obj, 'BackgroundColor', theme.color.panel);

end

function local_style_uicontrol(obj, theme)

style = '';
try
    style = lower(char(obj.Style));
catch
end

local_set(obj, 'FontName', theme.font.name);
ctrl_h = inf;
try
    u = obj.Units;
    obj.Units = 'pixels';
    ctrl_h = obj.Position(4);
    obj.Units = u;
catch
end
fit_fs = theme.font.size;
if isfinite(ctrl_h)
    local_set(obj, 'FontUnits', 'pixels');
    fit_fs = min(theme.font.size, max(9, ctrl_h - 5));
end

switch style
    case {'text'}
        tag = '';
        try
            tag = char(obj.Tag);
        catch
        end
        if length(tag) > 4 && strcmp(tag(end-3:end), '_cap')
            cap_fg = theme.color.buttonText;
            try
                btn = obj.UserData;
                if ~isempty(btn) && isgraphics(btn) && isvalid(btn) ...
                        && isappdata(btn, 'ZefRoundPrimary') ...
                        && isequal(getappdata(btn, 'ZefRoundPrimary'), true)
                    cap_fg = theme.color.primaryText;
                end
            catch
            end
            local_set(obj, 'ForegroundColor', cap_fg);
            local_set(obj, 'FontName', theme.font.name);
            local_set(obj, 'FontSize', fit_fs);
            return
        end
        local_set(obj, 'FontSize', fit_fs);
        local_set(obj, 'ForegroundColor', theme.color.text);
        if ~strncmp(tag, 'zef_', 4) && ~strncmp(tag, 'status_', 7) ...
                && ~strncmp(tag, 'section_', 8) && ~strncmp(tag, 'label_', 6)
            local_fit_text_extent(obj, fit_fs);
        end
        parent_bg = theme.color.bg;
        try
            if isprop(obj.Parent, 'BackgroundColor')
                parent_bg = obj.Parent.BackgroundColor;
            end
        catch
        end
        local_set(obj, 'BackgroundColor', parent_bg);
        if strcmp(tag, 'zef_nav_sep') || strcmp(tag, 'zef_tool_sep') ...
                || strcmp(tag, 'zef_tab_rule') || strcmp(tag, 'zef_header_rule') ...
                || strcmp(tag, 'zef_tool_rule') || strncmp(tag, 'zef_card_e_', 11)
            edge_c = theme.color.border;
            try
                if strncmp(tag, 'zef_card_e_', 11)
                    edge_c = theme.color.cardEdge;
                end
            catch
            end
            local_set(obj, 'BackgroundColor', edge_c);
            return
        end
        try
            ptag = '';
            if isprop(obj.Parent, 'Tag')
                ptag = char(obj.Parent.Tag);
            end
            if strcmp(ptag, 'figure_sidebar') || strcmp(ptag, 'figure_lists') ...
                    || strcmp(ptag, 'figure_toggle_host')
                parent_bg = theme.color.panel;
                local_set(obj, 'BackgroundColor', parent_bg);
            end
        catch
        end
        if strcmp(tag, 'zef_tab_underline')
            local_set(obj, 'BackgroundColor', theme.color.accent);
            return
        end
        if strncmp(tag, 'section_', 8)
            local_set(obj, 'FontWeight', 'bold');
            local_set(obj, 'ForegroundColor', theme.color.header);
            local_set(obj, 'FontSize', min(theme.font.size, max(10, ctrl_h - 6)));
        elseif contains(tag, 'copyright')
            local_set(obj, 'FontSize', theme.font.sizeSmall);
            local_set(obj, 'ForegroundColor', theme.color.textMuted);
        elseif strncmp(tag, 'zef_nav_', 8)
            local_set(obj, 'BackgroundColor', theme.color.panel);
            local_set(obj, 'ForegroundColor', theme.color.text);
            local_set(obj, 'HorizontalAlignment', 'left');
        elseif strncmp(tag, 'zef_tab_', 8)
            local_set(obj, 'BackgroundColor', theme.color.workspace);
            if contains(tag, 'figure') && isequal(obj.UserData, 1)
                local_set(obj, 'ForegroundColor', theme.color.accent);
            else
                local_set(obj, 'ForegroundColor', theme.color.textMuted);
            end
        elseif strcmp(tag, 'status_ready')
            fg = theme.color.ready;
            try
                fg = theme.color.readyText;
            catch
            end
            local_set(obj, 'ForegroundColor', fg);
        elseif strcmp(tag, 'status_ready_dot')
            local_set(obj, 'BackgroundColor', theme.color.ready);
            return
        elseif strncmp(tag, 'status_sep', 10)
            local_set(obj, 'BackgroundColor', theme.color.border);
            return
        elseif strcmp(tag, 'status_ready_pill')
            local_set(obj, 'BackgroundColor', theme.color.panelAlt);
            return
        elseif strncmp(tag, 'zef_tool_lab_', 13)
            local_set(obj, 'BackgroundColor', theme.color.workspace);
            local_set(obj, 'ForegroundColor', theme.color.text);
        elseif strcmp(tag, 'zef_shell_header_sub')
            local_set(obj, 'ForegroundColor', theme.color.accent);
            local_set(obj, 'BackgroundColor', theme.color.headerBg);
        elseif strncmp(tag, 'zef_shell_brand', 15) || strcmp(tag, 'zef_shell_title')
            try
                if isprop(obj.Parent, 'BackgroundColor')
                    local_set(obj, 'BackgroundColor', obj.Parent.BackgroundColor);
                end
            catch
            end
            if strcmp(tag, 'zef_shell_brand_sub')
                local_set(obj, 'ForegroundColor', theme.color.accent);
            elseif strcmp(tag, 'zef_shell_title') || strcmp(tag, 'zef_shell_brand_title')
                local_set(obj, 'ForegroundColor', theme.color.text);
                local_set(obj, 'FontWeight', 'bold');
            end
        end
    case {'pushbutton', 'togglebutton'}
        tag = '';
        try
            tag = char(obj.Tag);
        catch
        end
        if strcmp(tag, 'zef_card_bg') || strncmp(tag, 'zef_card_c_', 11) ...
                || strncmp(tag, 'zef_nav_fill_', 13) || strcmp(tag, 'zef_flyout_fill')
            return
        end
        if ~(strncmp(tag, 'zef_tool_', 9) || strncmp(tag, 'zef_nav_', 8) ...
                || strcmp(tag, 'zef_shell_help') || strcmp(tag, 'zef_shell_bell') ...
                || strcmp(tag, 'zef_shell_profile') ...
                || contains(tag, 'header_mark') || contains(tag, 'header_logo') ...
                || contains(tag, 'brand_mark'))
            local_style_button(obj, theme);
        end
        local_set(obj, 'FontSize', fit_fs);
        if strncmp(tag, 'zef_nav_icon_', 13) || strncmp(tag, 'zef_nav_hit_', 12)
            local_set(obj, 'BackgroundColor', theme.color.panel);
            local_set(obj, 'ForegroundColor', theme.color.panel);
        elseif strncmp(tag, 'zef_nav_', 8)
            local_set(obj, 'BackgroundColor', theme.color.panel);
            local_set(obj, 'ForegroundColor', theme.color.text);
            local_set(obj, 'HorizontalAlignment', 'left');
            local_set(obj, 'FontWeight', 'normal');
        elseif strcmp(tag, 'zef_axes_gizmo')
            local_set(obj, 'BackgroundColor', theme.color.axesBg);
            local_set(obj, 'ForegroundColor', theme.color.axesBg);
        elseif strncmp(tag, 'zef_tab_', 8)
            local_set(obj, 'BackgroundColor', theme.color.workspace);
            local_set(obj, 'ForegroundColor', theme.color.textMuted);
        elseif strcmp(tag, 'status_ready_pill')
            local_set(obj, 'BackgroundColor', theme.color.panelAlt);
        elseif strncmp(tag, 'zef_tool_', 9)
            local_set(obj, 'BackgroundColor', theme.color.workspace);
            local_set(obj, 'ForegroundColor', theme.color.text);
            local_set(obj, 'FontWeight', 'normal');
        elseif contains(tag, 'brand_mark') || contains(tag, 'header_mark') ...
                || contains(tag, 'header_logo') ...
                || strcmp(tag, 'zef_shell_help') ...
                || strcmp(tag, 'zef_shell_bell') || strcmp(tag, 'zef_shell_profile')
            local_set(obj, 'BackgroundColor', theme.color.headerBg);
            if contains(tag, 'brand')
                local_set(obj, 'BackgroundColor', theme.color.navBg);
            end
        elseif strncmp(tag, 'status_', 7)
            local_set(obj, 'BackgroundColor', theme.color.panel);
            if strcmp(tag, 'status_ready_dot')
                local_set(obj, 'BackgroundColor', theme.color.panelAlt);
            end
        elseif strncmp(tag, 'zef_shell_', 10)
            local_set(obj, 'BackgroundColor', theme.color.button);
        end
    case {'edit', 'popupmenu', 'listbox'}
        local_set(obj, 'FontSize', min(fit_fs, theme.font.size));
        local_set(obj, 'BackgroundColor', theme.color.inputBg);
        local_set(obj, 'ForegroundColor', theme.color.text);
    case {'checkbox', 'radiobutton'}
        local_set(obj, 'FontSize', fit_fs);
        local_set(obj, 'ForegroundColor', theme.color.text);
        cb_bg = theme.color.bg;
        try
            if isprop(obj.Parent, 'Tag') && strcmp(char(obj.Parent.Tag), 'figure_sidebar')
                cb_bg = theme.color.panel;
            end
        catch
        end
        local_set(obj, 'BackgroundColor', cb_bg);
    case {'slider'}
        local_set(obj, 'BackgroundColor', theme.color.panelAlt);
        local_set(obj, 'ForegroundColor', theme.color.accent);
    otherwise
        local_set(obj, 'FontSize', fit_fs);
end

end

function local_set(obj, prop, value)

try
    if isprop(obj, prop)
        set(obj, prop, value);
    end
catch
end

end

function local_try_radius(obj, theme, radius)

if nargin < 3 || isempty(radius)
    radius = 6;
    try
        radius = theme.space.btnRadius;
    catch
    end
end
try
    if isprop(obj, 'CornerRadius')
        obj.CornerRadius = radius;
    end
catch
end

end

function local_style_axes(obj, theme)

try
    obj.Color = theme.color.axesBg;
catch
end
try
    obj.XColor = theme.color.textMuted;
    obj.YColor = theme.color.textMuted;
    obj.ZColor = theme.color.textMuted;
catch
end
try
    obj.GridColor = theme.color.border;
    obj.MinorGridColor = theme.color.border;
catch
end
try
    obj.Box = 'off';
catch
end

end

function local_blend_logo(obj, theme)

zef_ui_blend_logo(obj, theme);

end

function local_fit_text_extent(obj, fit_fs)

try
    maxv = 1;
    if isprop(obj, 'Max')
        maxv = double(obj.Max);
    end
    if maxv > 1
        return
    end
    str = '';
    if ischar(obj.String) || isstring(obj.String)
        str = strtrim(char(obj.String));
    elseif iscell(obj.String) && ~isempty(obj.String)
        str = strtrim(char(string(obj.String{1})));
    end
    if numel(str) < 12
        return
    end
    u = obj.Units;
    obj.Units = 'pixels';
    w = obj.Position(3);
    fs = fit_fs;
    while fs > 9 && (0.56 * fs * numel(str)) > w
        fs = fs - 1;
    end
    obj.FontSize = fs;
    obj.Units = u;
catch
end

end
