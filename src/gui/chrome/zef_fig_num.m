function fig_num = zef_fig_num
%ZEF_FIG_NUM  Next unused Figure-tool ZefFig index.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   findobj(groot, '-property','ZefFig'), max of those values, plus one.
%   zef_figure_tool stores the result in the figure's ZefFig property.
%   The unified Figure-tool window keeps a stable Name without a trailing
%   index; extra copies append " 2", " 3". zef_import_figure and
%   zef_size_change also call this to index zef.zeffiro_current_size.
%
%   fig_num = zef_fig_num
%
%   Output
%     fig_num - scalar; 1 when no ZefFig figures exist.
%
%   See also zef_figure_tool, zef_size_change.
h_fig_aux = findobj(groot, '-property','ZefFig');

max_tag = 0;
for i = 1 : length(h_fig_aux)
    tag_val = get(h_fig_aux(i),'ZefFig');
    if not(isempty(tag_val))
        max_tag = max(max_tag,tag_val);
    end
end

fig_num = max_tag + 1;

end
