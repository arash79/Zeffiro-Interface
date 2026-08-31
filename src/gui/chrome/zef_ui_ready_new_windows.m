function zef_ui_ready_new_windows()
%ZEF_UI_READY_NEW_WINDOWS  Theme plugin figures that skipped zef_ui_ready.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   INI plugin callbacks are often scripts, so they never pass through
%   zef_tool_start. After those callbacks run, theme any Zeffiro figure
%   that has not already been marked ZefUiThemed.
%
%   See also zef_plugin, zef_ui_ready.

figs = findall(groot, 'Type', 'figure');
for i = 1:numel(figs)
    fig = figs(i);
    if isempty(fig) || ~isvalid(fig)
        continue
    end
    try
        if isappdata(fig, 'ZefUiThemed')
            continue
        end
    catch
    end
    tag = '';
    name = '';
    try
        tag = char(fig.Tag);
    catch
    end
    try
        name = char(fig.Name);
    catch
    end
    if strcmp(tag, 'progress_bar')
        continue
    end
    if ~(contains(name, 'ZEFFIRO Interface') || strcmp(tag, 'figure_tool') ...
            || contains(lower(name), 'zeffiro'))
        continue
    end
    try
        zef_ui_ready(fig);
    catch
    end
end

end
