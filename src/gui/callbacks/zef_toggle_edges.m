function zef_toggle_edges
%ZEF_TOGGLE_EDGES  Flip mesh EdgeColor on the current Figure-tool axes.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Figure tool button **Toggle edges** (h_toggle_edges; Callback
%   "zef_toggle_edges;"). Function with no arguments.
%
%   Finds gcf children Tag axes1, then each grandchild with an EdgeColor
%   property: if EdgeColor is the on-color (theme text, or legacy white
%   from the removed dark appearance), sets 'none'; otherwise sets the
%   on-color.
%
%   See also zef_toggle_figure_controls, zef_figure_tool.

h = zef_ui_axes();
if isempty(h)
    return
end
on_color = [0.145 0.175 0.210];
try
    th = zef_ui_theme();
    on_color = th.color.text;
catch
end
h = get(h(1), 'Children');
for i = 1 : length(h)
    if find(ismember(properties(h(i)), 'EdgeColor'))
        ec = h(i).EdgeColor;
        if isequal(ec, on_color) || isequal(ec, [1 1 1])
            set(h(i), 'edgecolor', 'none');
        else
            set(h(i), 'edgecolor', on_color);
        end
    end
end

end
