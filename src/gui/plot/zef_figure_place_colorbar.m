function h_cb = zef_figure_place_colorbar(ax, mode)
%ZEF_FIGURE_PLACE_COLORBAR  Colorbar that does not steal the plot slot.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   EastOutside colorbars change axes TightInset and walk the plot out of
%   the Figure card. The colorbar stays on the axes' parent (a figure and
%   its axes must share a parent; figure_view is a uipanel). Location
%   'manual' freezes whatever Position is current. Immediately after
%   colorbar() that Position is still the default normalized [0 0 1 1],
%   so the bar becomes the whole figure view and paints the colormap over
%   the mesh. This helper writes an explicit narrow pixel strip instead.
%
%   h_cb = zef_figure_place_colorbar(ax)
%   h_cb = zef_figure_place_colorbar(ax, 'reposition')
%
%   'reposition' only moves an existing Tag='rightColorbar'. The Figure
%   layout and zef_figure_sync_plot use that after they change the axes
%   position.
%
%   See also zef_figure_tool_layout, zef_figure_sync_plot.

h_cb = [];
if nargin < 1 || isempty(ax) || ~isgraphics(ax) || ~isvalid(ax)
    return
end
if nargin < 2 || isempty(mode)
    mode = 'create';
end
reposition = strcmpi(char(string(mode)), 'reposition');

h_fig = ancestor(ax, 'figure');
if reposition
    if isempty(h_fig)
        return
    end
    old = findall(h_fig, 'Tag', 'rightColorbar');
    if isempty(old) || ~isvalid(old(1))
        return
    end
    h_cb = old(1);
    local_pin(h_cb, ax);
    return
end

if ~isempty(h_fig)
    old = findall(h_fig, '-regexp', 'Tag', 'Colorbar');
    for i = 1:numel(old)
        try
            if isvalid(old(i))
                delete(old(i));
            end
        catch
        end
    end
end

ax_units = ax.Units;
ax.Units = 'pixels';
saved_pos = ax.Position;
saved_inner = [];
try
    saved_inner = ax.InnerPosition;
catch
end

try
    h_cb = colorbar(ax);
catch
    try
        h_cb = colorbar('peer', ax);
    catch
        ax.Units = ax_units;
        return
    end
end

% EastOutside has already shrunk the axes. Put the plot slot back, then
% park the bar in a narrow strip. Do this after Location='manual': that
% switch freezes Position, and the frozen value is still [0 0 1 1] until
% an explicit rectangle replaces it.
try
    ax.Units = 'pixels';
    ax.Position = saved_pos;
catch
end
try
    if ~isempty(saved_inner)
        ax.InnerPosition = saved_inner;
    end
catch
end
try
    ax.Units = ax_units;
catch
end

try
    h_cb.Tag = 'rightColorbar';
catch
end
local_pin(h_cb, ax);

end

function local_pin(h_cb, ax)

if isempty(h_cb) || ~isvalid(h_cb) || isempty(ax) || ~isvalid(ax)
    return
end
try
    if ~isequal(h_cb.Parent, ax.Parent)
        h_cb.Parent = ax.Parent;
    end
catch
end
try
    h_cb.Location = 'manual';
catch
end
ax_units = ax.Units;
ax.Units = 'pixels';
ap = ax.Position;
try
    inner = ax.InnerPosition;
    if numel(inner) >= 4 && all(isfinite(inner)) && inner(3) > 2 && inner(4) > 2
        ap = inner;
    end
catch
end
try
    ax.Units = ax_units;
catch
end
bar_w = 14;
margin = 8;
x = ap(1) + ap(3) - bar_w - 4;
y = ap(2) + margin;
hgt = max(48, ap(4) - 2 * margin);
if x < ap(1)
    x = ap(1) + max(0, ap(3) - bar_w);
end
try
    h_cb.Units = 'pixels';
    h_cb.Position = [x, y, bar_w, hgt];
catch
end

end
