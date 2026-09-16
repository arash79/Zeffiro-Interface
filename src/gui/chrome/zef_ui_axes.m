function h = zef_ui_axes(h_figure)
%ZEF_UI_AXES  Live Figure-tool axes, even after cla('reset') drops Tag.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Figure-tool callbacks used to find axes1 with findobj on the figure's
%   direct Children, then with findall by Tag. The redesign parents
%   sliders into a sidebar (so nested findall is required for controls)
%   and the logo path calls cla(..., 'reset'), which clears Tag. Tag
%   lookup then returns a GraphicsPlaceholder and CLim/Children/Colormap
%   fail. This helper returns the live uiaxes/axes on h_figure, preferring
%   zef.h_axes1 when it belongs to that figure, and writes Tag='axes1'
%   back so later Tag-based code keeps working.
%
%   h = zef_ui_axes
%   h = zef_ui_axes(h_figure)
%
%   See also zef_ui_control, zef_figure_tool, zef_logoplot.

h = gobjects(0);
if nargin < 1
    h_figure = [];
end
h_figure = local_figure(h_figure);

if local_is_fig(h_figure)
    h = local_find_axes(h_figure);
    if local_is_axes(h)
        local_ensure_tag(h);
        return
    end
end

try
    zef = evalin('base', 'zef');
catch
    zef = struct();
end
if isstruct(zef) && isfield(zef, 'h_axes1') && local_is_axes(zef.h_axes1)
    if ~local_is_fig(h_figure) ...
            || isequal(ancestor(zef.h_axes1, 'figure'), h_figure)
        h = zef.h_axes1;
        local_ensure_tag(h);
        return
    end
end
if isstruct(zef) && isfield(zef, 'h_zeffiro') && local_is_fig(zef.h_zeffiro)
    h = local_find_axes(zef.h_zeffiro);
    if local_is_axes(h)
        local_ensure_tag(h);
    end
end

end

function fig = local_figure(h_figure)

fig = [];
if local_is_fig(h_figure)
    fig = h_figure;
    return
end
try
    zef = evalin('base', 'zef');
    if isstruct(zef) && isfield(zef, 'h_zeffiro') && local_is_fig(zef.h_zeffiro)
        fig = zef.h_zeffiro;
        return
    end
catch
end
try
    fig = gcf;
    if ~local_is_fig(fig)
        fig = [];
    end
catch
    fig = [];
end

end

function h = local_find_axes(fig)

h = gobjects(0);
if ~local_is_fig(fig)
    return
end
found = findall(fig, 'Tag', 'axes1');
h = local_first_axes(found);
if local_is_axes(h)
    return
end
found = [findall(fig, 'Type', 'uiaxes'); findall(fig, 'Type', 'axes')];
h = local_first_axes(found);

end

function h = local_first_axes(found)

h = gobjects(0);
for i = 1:numel(found)
    if local_is_axes(found(i)) && ~local_is_chrome_axes(found(i))
        h = found(i);
        return
    end
end

end

function tf = local_is_chrome_axes(h)

tf = false;
tag = '';
try
    tag = char(h.Tag);
catch
end
if strcmp(tag, 'zef_card_bg') || strcmp(tag, 'zef_card_img') ...
        || strncmp(tag, 'zef_card_', 9) || strncmp(tag, 'zef_nav_bg_', 11) ...
        || strcmp(tag, 'zef_fly_bg')
    tf = true;
    return
end
try
    if ~strcmp(tag, 'axes1') && strcmpi(char(h.HandleVisibility), 'off')
        tf = true;
    end
catch
end

end

function tf = local_is_axes(h)

tf = false;
if isempty(h)
    return
end
try
    if ~isgraphics(h) || ~isvalid(h)
        return
    end
    typ = lower(char(h(1).Type));
    tf = any(strcmp(typ, {'axes', 'uiaxes'}));
catch
end

end

function tf = local_is_fig(h)

tf = false;
try
    tf = ~isempty(h) && isgraphics(h) && isvalid(h) ...
        && any(strcmpi(char(h.Type), {'figure', 'uifigure'}));
catch
end

end

function local_ensure_tag(h)

try
    if local_is_axes(h) && ~strcmp(char(h.Tag), 'axes1')
        h.Tag = 'axes1';
    end
catch
end

end
