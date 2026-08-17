function zef_ui_ready(h)
%ZEF_UI_READY  Apply the shared theme and, when known, a window layout.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called after a tool, settings dialog, or plugin figure is built.
%   Theme is always applied. Named core windows also get a dedicated
%   layout pass so spacing matches the figure tool.
%
%   zef_ui_ready(h)
%
%   See also zef_ui_apply_theme, zef_ui_theme.

if nargin < 1 || isempty(h) || ~isgraphics(h) || ~isvalid(h)
    return
end

name = '';
try
    name = char(get(h, 'Name'));
catch
end
tag = '';
try
    tag = char(get(h, 'Tag'));
catch
end

try
    if contains(name, 'Figure tool') && ~contains(name, 'axes popup')
        zef_figure_tool_layout(h);
    elseif contains(name, 'Mesh visualization tool')
        zef_layout_mesh_visualization_tool(h);
    elseif contains(name, 'Mesh tool')
        zef_layout_mesh_tool(h);
    elseif contains(name, 'Segmentation tool')
        zef_layout_segmentation_tool(h);
    elseif contains(name, 'Menu tool')
        zef_layout_menu_tool(h);
    elseif contains(name, 'Parcellation')
        zef_layout_parcellation_tool(h);
    elseif any(contains(lower(name), {'settings', 'profile', 'options', 'processing'}))
        if ~isempty(findall(h, 'Type', 'uitable'))
            zef_layout_table_dialog(h);
        else
            zef_layout_form_dialog(h);
        end
    elseif ~contains(name, 'Figure tool') && ~strcmp(tag, 'progress_bar')
        zef_layout_guide_window(h);
    end
catch
end

zef_ui_apply_theme(h);

is_menu = contains(name, 'Menu tool');
is_wait = strcmp(tag, 'progress_bar');
try
    % Layouts already chose a content-based size and stored ZefMinSize.
    % Do not inflate those windows back to a generic 240 px floor.
    if ~is_menu && ~is_wait && ~isappdata(h, 'ZefMinSize')
        fig_pos = h.Position;
        if numel(fig_pos) >= 4 && fig_pos(3) < 360
            h.Position(3) = 360;
        end
        if numel(fig_pos) >= 4 && fig_pos(4) < 180
            h.Position(4) = 180;
        end
    end
catch
end

if ~is_menu && ~is_wait && isappdata(h, 'ZefMinSize')
    try
        mins = getappdata(h, 'ZefMinSize');
        zef_ui_bind_min_size(h, mins(1), mins(2));
        zef_ui_adapt_grid(h);
    catch
    end
end

if contains(name, 'ZEFFIRO Interface') || strcmp(tag, 'progress_bar') ...
        || contains(lower(name), 'zeffiro')
    try
        zef_window_manager('standalone', h);
    catch
    end
end

end
