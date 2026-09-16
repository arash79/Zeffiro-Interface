function zef_figure_sync_plot(h_fig)
%ZEF_FIGURE_SYNC_PLOT  Restore Figure-tool axes after a volume/surface draw.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Plotters may change CurrentAxes or Units. Restore the axes handle and
%   keep InnerPosition inside figure_view when the plot moved it. Do not
%   run a full chrome layout: that restacks children and freezes resize.
%
%   zef_figure_sync_plot
%   zef_figure_sync_plot(h_fig)
%
%   See also zef_figure_tool_layout, zef_figure_time_label.

if nargin < 1 || isempty(h_fig)
    try
        h_fig = evalin('base', 'zef.h_zeffiro');
    catch
        h_fig = [];
    end
end
if isempty(h_fig) || ~isgraphics(h_fig) || ~isvalid(h_fig)
    return
end
old = findall(h_fig, 'Tag', 'image_details');
for i = 1:numel(old)
    try
        if isgraphics(old(i)) && isvalid(old(i)) ...
                && any(strcmpi(char(old(i).Type), {'axes', 'uiaxes'}))
            delete(old(i));
        end
    catch
    end
end
ax = [];
try
    ax = zef_ui_axes(h_fig);
catch
    ax = findall(h_fig, 'Tag', 'axes1');
end
if ~isempty(ax) && isvalid(ax(1))
    try
        set(h_fig, 'CurrentAxes', ax(1));
    catch
    end
    try
        ax(1).Units = 'pixels';
        ax(1).Tag = 'axes1';
    catch
    end
    view = [];
    try
        view = findall(h_fig, 'Tag', 'figure_view');
    catch
    end
    if ~isempty(view) && isvalid(view(1))
        try
            if ~isequal(ax(1).Parent, view(1))
                ax(1).Parent = view(1);
            end
        catch
        end
        try
            view(1).Units = 'pixels';
            vp = double(view(1).Position);
            slot = [1, 1, max(1, vp(3) - 2), max(1, vp(4) - 2)];
            cur = double(ax(1).InnerPosition);
            if numel(cur) < 4 || max(abs(cur(:) - slot(:))) >= 1
                ax(1).InnerPosition = slot;
            end
        catch
        end
    end
    try
        setappdata(ax(1), 'ZefHasVolumePlot', true);
    catch
    end
    try
        zef_figure_interact(h_fig, 'reapply');
    catch
    end
end

end
