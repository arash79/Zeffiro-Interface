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
%   See also zef_ui_theme, zef_ui_ready.

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
    if isprop(h, 'Icon')
        icon_file = which('zeffiro_small_logo.png');
        if isempty(icon_file)
            icon_file = which('zeffiro_logo_compass.png');
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

switch typ
    case {'axes', 'uiaxes', 'legend', 'colorbar', 'image', 'light', 'surface', ...
            'patch', 'line', 'text', 'uihtml', 'webprovider'}
        return
    case {'uiimage'}
        try
            obj.ScaleMethod = 'fit';
            obj.BackgroundColor = theme.color.bg;
            obj.VerticalAlignment = 'center';
        catch
        end
        try
            local_blend_logo(obj, theme);
        catch
        end
        return
    case {'uigridlayout'}
        % Nested section cards keep the panel color set by the layout.
        % Only the tagged root grid is painted with the window background.
        try
            if strcmp(char(obj.Tag), 'zef_ui_root')
                obj.BackgroundColor = theme.color.bg;
            end
        catch
        end
        return
    case {'uipanel', 'panel'}
        local_set(obj, 'BackgroundColor', theme.color.panel);
        local_set(obj, 'ForegroundColor', theme.color.text);
        local_set(obj, 'HighlightColor', theme.color.border);
        local_set(obj, 'BorderColor', theme.color.border);
        local_set(obj, 'FontName', theme.font.name);
        local_set(obj, 'FontSize', theme.font.sizeSmall);
        local_set(obj, 'FontWeight', 'bold');
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
        'Run script', 'Apply', 'Save', 'Plot', 'Start', 'Start inversion', ...
        'Find currents', 'Interpolate', 'Plot hyperprior'})) ...
        || (contains(lower(txt), 'create') && contains(lower(txt), 'fem'));
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
local_set(obj, 'FontName', theme.font.name);
local_set(obj, 'FontSize', theme.font.size);
local_set(obj, 'FontWeight', 'normal');

end

function local_style_label(obj, theme)

local_set(obj, 'FontName', theme.font.name);
local_set(obj, 'FontSize', theme.font.size);
local_set(obj, 'FontColor', theme.color.text);
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

end

function local_style_table(obj, theme)

local_set(obj, 'FontName', theme.font.name);
local_set(obj, 'FontSize', theme.font.size);
local_set(obj, 'FontColor', theme.color.text);
local_set(obj, 'ForegroundColor', theme.color.text);
try
    obj.RowStriping = 'on';
    obj.BackgroundColor = [1.000 1.000 1.000; 0.948 0.956 0.960];
catch
    local_set(obj, 'BackgroundColor', [1 1 1]);
end
try
    obj.RowHeight = theme.space.tableRow;
catch
end
try
    st = uistyle('FontColor', theme.color.text, ...
        'FontName', theme.font.name, 'FontSize', theme.font.size, ...
        'HorizontalAlignment', 'left');
    removeStyle(obj);
    addStyle(obj, st);
catch
end
zef_ui_fit_table(obj);

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
        local_set(obj, 'FontSize', fit_fs);
        local_set(obj, 'ForegroundColor', theme.color.text);
        parent_bg = theme.color.bg;
        try
            if isprop(obj.Parent, 'BackgroundColor')
                parent_bg = obj.Parent.BackgroundColor;
            end
        catch
        end
        local_set(obj, 'BackgroundColor', parent_bg);
        tag = '';
        try
            tag = char(obj.Tag);
        catch
        end
        if contains(tag, {'section', 'header'})
            local_set(obj, 'FontWeight', 'bold');
            local_set(obj, 'ForegroundColor', theme.color.header);
            local_set(obj, 'FontSize', min(theme.font.size, max(10, ctrl_h - 6)));
        elseif contains(tag, 'copyright')
            local_set(obj, 'FontSize', theme.font.sizeSmall);
            local_set(obj, 'ForegroundColor', theme.color.textMuted);
        end
    case {'pushbutton', 'togglebutton'}
        local_style_button(obj, theme);
        local_set(obj, 'FontSize', fit_fs);
    case {'edit', 'popupmenu', 'listbox'}
        local_set(obj, 'FontSize', min(fit_fs, theme.font.size));
        local_set(obj, 'BackgroundColor', theme.color.inputBg);
        local_set(obj, 'ForegroundColor', theme.color.text);
    case {'checkbox', 'radiobutton'}
        local_set(obj, 'FontSize', fit_fs);
        local_set(obj, 'ForegroundColor', theme.color.text);
        local_set(obj, 'BackgroundColor', theme.color.bg);
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

function local_blend_logo(obj, theme)

if isappdata(obj, 'ZefLogoBlended') && isequal(getappdata(obj, 'ZefLogoBlended'), true)
    return
end
src = [];
try
    src = obj.ImageSource;
catch
    return
end
img = [];
try
    if isnumeric(src)
        img = src;
    elseif (ischar(src) || isstring(src)) && strlength(src) > 0
        img = imread(char(src));
    end
catch
    return
end
if isempty(img) || ndims(img) < 2
    return
end
bg8 = uint8(round(255 * theme.color.bg));
try
    if size(img, 3) >= 3
        img = im2uint8(img);
        near_white = max(abs(double(img) - 255), [], 3) < 18;
        for k = 1:min(3, size(img, 3))
            ch = img(:, :, k);
            ch(near_white) = bg8(k);
            img(:, :, k) = ch;
        end
        obj.ImageSource = img;
        setappdata(obj, 'ZefLogoBlended', true);
    end
catch
end

end
