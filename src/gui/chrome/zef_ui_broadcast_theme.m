function zef_ui_broadcast_theme(theme)
%ZEF_UI_BROADCAST_THEME  Restyle every open Zeffiro window from shared tokens.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Restyle every open Zeffiro window from the canonical UI tokens.
%   Call after a token change (font size, etc.) so already-open tools,
%   settings dialogs, and colored lists pick up the current palette.
%
%   zef_ui_broadcast_theme
%   zef_ui_broadcast_theme(theme)
%
%   See also zef_ui_theme, zef_ui_apply_theme, zef_ui_shell.

if nargin < 1 || isempty(theme)
    theme = zef_ui_theme();
end

try
    zef_waitbar('theme');
catch
end

figs = findall(groot, 'Type', 'figure');
for i = 1:numel(figs)
    fig = figs(i);
    if isempty(fig) || ~isvalid(fig)
        continue
    end
    if ~local_is_zef_window(fig)
        continue
    end
    tag = '';
    try
        tag = char(fig.Tag);
    catch
    end
    if strcmp(tag, 'progress_bar')
        continue
    end
    try
        if zef_ui_is_unified(fig) || strcmp(tag, 'figure_tool')
            zef_ui_shell('theme', fig);
        else
            zef_ui_apply_theme(fig, theme);
            zef_ui_polish_window(fig, theme);
        end
    catch
    end
end

lists = findall(groot, 'Type', 'uihtml');
for i = 1:numel(lists)
    try
        zef_colored_list('theme', lists(i));
    catch
    end
end

end

function tf = local_is_zef_window(fig)

tf = false;
try
    tag = char(fig.Tag);
    name = char(fig.Name);
    tf = contains(name, 'ZEFFIRO Interface') || strcmp(tag, 'figure_tool') ...
        || strcmp(tag, 'progress_bar') || contains(lower(name), 'zeffiro');
    if ~tf && isprop(fig, 'ZefTool')
        tf = true;
    end
catch
end

end
