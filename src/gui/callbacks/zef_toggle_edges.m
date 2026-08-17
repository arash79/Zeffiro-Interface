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
%   property: if EdgeColor is white [1 1 1], sets 'none'; otherwise sets
%   [1 1 1].
%
%   See also zef_toggle_figure_controls, zef_figure_tool.

h = zef_ui_axes(gcf);
if isempty(h)
    return
end
h = get(h(1), 'Children');
for i = 1 : length(h);
    if find(ismember(properties(h(i)),'EdgeColor'));
        if isequal(h(i).EdgeColor,[1 1 1])
            set(h(i),'edgecolor','none');
        else
            set(h(i),'edgecolor',[1 1 1]);
        end
    end

end

end
