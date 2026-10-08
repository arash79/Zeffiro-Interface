function fig = zef_strip_burr_notice(message, varargin)
%ZEF_STRIP_BURR_NOTICE  Modal OK dialog for a burr-hole warning or error.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   One OK button. The button and the window close box both dismiss the
%   dialog. Pass 'Wait', false to create the window without blocking, for
%   tests that click OK themselves.
%
%   zef_strip_burr_notice(message)
%   fig = zef_strip_burr_notice(message, 'Wait', false)
%
%   See also zef_strip_burr_dialogs, zef_ui_confirm.

if nargin < 1 || isempty(message)
    message = '';
end
message = char(string(message));
wait_for = true;
title = 'ZEFFIRO Interface: Burr hole';
i = 1;
while i <= numel(varargin)
    arg = varargin{i};
    if (ischar(arg) || isstring(arg)) && strcmpi(strtrim(char(arg)), 'Wait') ...
            && i < numel(varargin)
        wait_for = logical(varargin{i + 1});
        i = i + 2;
        continue
    end
    if (ischar(arg) || isstring(arg)) && ~isempty(strtrim(char(arg)))
        title = char(arg);
    end
    i = i + 1;
end

theme = zef_ui_theme();
style = 'modal';
if ~wait_for
    style = 'normal';
end
fig = uifigure( ...
    'Name', 'ZEFFIRO Interface: Burr hole', ...
    'Tag', 'zef_burr_notice', ...
    'WindowStyle', style, ...
    'Resize', 'on', ...
    'Color', theme.color.bg, ...
    'Position', [180 180 460 220], ...
    'Visible', 'off');
try
    zef_window_manager('standalone', fig);
catch
end

gl = uigridlayout(fig, [3 3]);
gl.Tag = 'zef_ui_root';
gl.RowHeight = {26, '1x', 36};
gl.ColumnWidth = {'1x', 96, '1x'};
gl.Padding = [22 16 22 16];
gl.RowSpacing = 10;
gl.BackgroundColor = theme.color.bg;

title_lab = uilabel(gl, 'Text', title, ...
    'FontWeight', 'bold', 'FontSize', theme.font.sizeTitle, ...
    'FontColor', theme.color.text, 'HorizontalAlignment', 'left');
title_lab.Layout.Row = 1;
title_lab.Layout.Column = [1 3];
body = uilabel(gl, 'Text', message, ...
    'FontColor', theme.color.text, 'WordWrap', 'on', ...
    'HorizontalAlignment', 'left');
body.Layout.Row = 2;
body.Layout.Column = [1 3];
ok = uibutton(gl, 'Text', 'OK', 'Tag', 'zef_burr_notice_ok', ...
    'ButtonPushedFcn', @local_close);
ok.Layout.Row = 3;
ok.Layout.Column = 2;
try
    ok.BackgroundColor = theme.color.primary;
    ok.FontColor = theme.color.primaryText;
catch
end
fig.CloseRequestFcn = @local_close;
try
    zef_ui_apply_theme(fig, theme);
catch
end
fig.Visible = 'on';
try
    zef_window_manager('raise', fig);
catch
end
if ~wait_for
    return
end
uiwait(fig);
if isgraphics(fig) && isvalid(fig)
    delete(fig);
end
fig = gobjects(0);

    function local_close(src, ~)
        fig_h = ancestor(src, 'figure');
        if isempty(fig_h) || ~isgraphics(fig_h)
            return
        end
        try
            uiresume(fig_h);
        catch
        end
        if isgraphics(fig_h) && isvalid(fig_h)
            delete(fig_h);
        end
    end

end
