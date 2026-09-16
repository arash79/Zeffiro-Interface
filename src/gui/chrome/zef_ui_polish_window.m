function zef_ui_polish_window(h, theme)
%ZEF_UI_POLISH_WINDOW  Apply rounded chrome to a secondary Zeffiro window.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Traditional figures: card-paint uipanels and round pushbuttons.
%   Uifigures: CornerRadius on buttons and fields when MATLAB exposes it.
%   Skips the unified Figure-tool shell, the hidden menu owner, and the
%   waitbar so those keep their dedicated layouts.
%
%   zef_ui_polish_window(h)
%   zef_ui_polish_window(h, theme)
%
%   See also zef_ui_ready, zef_ui_round_button, zef_ui_card.

if nargin < 1 || isempty(h) || ~isgraphics(h) || ~isvalid(h)
    return
end
if nargin < 2 || isempty(theme)
    theme = zef_ui_theme();
end

fig = h;
try
    if ~strcmpi(char(h.Type), 'figure')
        fig = ancestor(h, 'figure');
    end
catch
end
if isempty(fig) || ~isvalid(fig)
    return
end

try
    if zef_ui_is_unified(fig)
        return
    end
catch
end
tag = '';
try
    tag = char(get(fig, 'Tag'));
catch
end
if strcmp(tag, 'figure_tool') || strcmp(tag, 'progress_bar') ...
        || strcmp(tag, 'h_zeffiro_menu')
    return
end
name = '';
try
    name = char(get(fig, 'Name'));
catch
end
if contains(name, 'Menu tool') || contains(name, 'Figure tool')
    return
end

if local_is_uifigure(fig)
    local_round_uifigure(fig, theme);
else
    local_round_guide(fig, theme);
end

end

function tf = local_is_uifigure(fig)

tf = false;
try
    tf = matlab.ui.internal.isUIFigure(fig);
    return
catch
end
try
    tf = isprop(fig, 'Scrollable');
catch
end

end

function local_round_uifigure(fig, theme)

r = 6;
try
    r = theme.space.btnRadius;
catch
end
objs = findall(fig);
for i = 1:numel(objs)
    obj = objs(i);
    if isempty(obj) || ~isvalid(obj)
        continue
    end
    cls = class(obj);
    try
        if contains(cls, 'Button') && ~contains(cls, 'ButtonGroup')
            local_try_radius(obj, r);
        elseif contains(cls, 'DropDown') || contains(cls, 'EditField') ...
                || contains(cls, 'TextArea') || contains(cls, 'Spinner')
            local_try_radius(obj, min(r, 4));
        elseif contains(cls, 'Panel') && ~contains(cls, 'Button')
            local_try_radius(obj, theme.space.cardRadius);
        end
    catch
    end
end

end

function local_round_guide(fig, theme)

try
    panels = findall(fig, 'Type', 'uipanel');
    for i = 1:numel(panels)
        ptag = '';
        try
            ptag = char(panels(i).Tag);
        catch
        end
        if strcmp(ptag, 'figure_sidebar') || strcmp(ptag, 'figure_lists') ...
                || strcmp(ptag, 'figure_toggle_host') ...
                || strncmp(ptag, 'zef_shell_', 10)
            continue
        end
        zef_ui_card(panels(i), theme);
    end
catch
end

btns = findall(fig, 'Type', 'uicontrol', 'Style', 'pushbutton');
tgl = findall(fig, 'Type', 'uicontrol', 'Style', 'togglebutton');
btns = [btns(:); tgl(:)];
for i = 1:numel(btns)
    b = btns(i);
    if isempty(b) || ~isvalid(b)
        continue
    end
    btag = '';
    try
        btag = char(b.Tag);
    catch
    end
    if strcmp(btag, 'zef_card_bg') || strncmp(btag, 'zef_card_', 9) ...
            || strncmp(btag, 'zef_shell_', 10) || strncmp(btag, 'zef_nav_', 8) ...
            || strncmp(btag, 'zef_tool_', 9) || strncmp(btag, 'zef_tab_', 8) ...
            || strncmp(btag, 'status_', 7) || strcmp(btag, 'zef_axes_gizmo') ...
            || length(btag) > 4 && strcmp(btag(end-3:end), '_cap')
        continue
    end
    is_primary = false;
    try
        lab = strtrim(char(b.String));
        if isempty(lab)
            lab = char(getappdata(b, 'ZefButtonLabel'));
        end
        is_primary = any(strcmpi(lab, { ...
            'Play', 'Apply', 'Save', 'Start', 'Start inversion', ...
            'Find currents', 'Plot', 'Plot graph', 'Run script', ...
            'Visualize volume', 'Create FEM mesh'}));
    catch
    end
    try
        zef_ui_round_button(b, theme, is_primary);
    catch
    end
end

end

function local_try_radius(obj, radius)

try
    if isprop(obj, 'CornerRadius')
        obj.CornerRadius = radius;
    end
catch
end

end
