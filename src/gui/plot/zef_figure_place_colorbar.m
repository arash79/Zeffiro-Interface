function h_cb = zef_figure_place_colorbar(ax)
%ZEF_FIGURE_PLACE_COLORBAR  Colorbar that does not steal the plot slot.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   EastOutside colorbars change axes TightInset and walk the plot out of
%   the Figure card. This helper builds a manual colorbar; pixel placement
%   is applied by zef_figure_tool_layout.
%
%   h_cb = zef_figure_place_colorbar(ax)
%
%   See also zef_figure_tool_layout, zef_figure_sync_plot.

h_cb = [];
if nargin < 1 || isempty(ax) || ~isgraphics(ax) || ~isvalid(ax)
    return
end
h_fig = ancestor(ax, 'figure');
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
try
    h_cb = colorbar(ax);
catch
    try
        h_cb = colorbar('peer', ax);
    catch
        return
    end
end
try
    h_fig = ancestor(ax, 'figure');
    if ~isempty(h_fig) && isvalid(h_fig)
        h_cb.Parent = h_fig;
    end
catch
end
try
    h_cb.Tag = 'rightColorbar';
catch
end
try
    h_cb.Location = 'manual';
catch
end
try
    h_cb.Units = 'pixels';
catch
end

end
