function zef_layout_menu_tool(fig)
%ZEF_LAYOUT_MENU_TOOL  Style the menu-bar window and logo.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   The menu bar stays a slim uifigure. The leftover hidden checkbox is
%   removed from the layout, the logo is padded, and the background uses
%   the shared theme.
%
%   See also zef_menu_tool, zef_set_menu_size.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end

theme = zef_ui_theme();
try
    fig.Color = theme.color.bg;
catch
end
try
    fig.Scrollable = 'off';
catch
end

cb = findall(fig, 'Type', 'uicheckbox');
for i = 1:numel(cb)
    try
        if strcmpi(char(cb(i).Visible), 'off')
            cb(i).Position = [1 1 1 1];
        end
    catch
    end
end

logo = findall(fig, 'Type', 'uiimage');
if isempty(logo)
    try
        zef = evalin('base', 'zef');
        if isfield(zef, 'h_menu_logo')
            logo = zef.h_menu_logo;
        end
    catch
    end
end
if ~isempty(logo) && isgraphics(logo(1)) && isvalid(logo(1))
    try
        fig.Units = 'pixels';
        pos = fig.Position;
        if pos(4) > 80
            pad = 20;
            avail_w = max(40, pos(3) - 2 * pad);
            avail_h = max(40, pos(4) - 2 * pad);
            logo(1).ScaleMethod = 'fit';
            logo(1).BackgroundColor = theme.color.bg;
            logo(1).HorizontalAlignment = 'center';
            logo(1).VerticalAlignment = 'center';
            logo(1).Position = [pad, pad, avail_w, avail_h];
        end
    catch
    end
end

end
