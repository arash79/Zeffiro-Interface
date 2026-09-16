function zef_about_dialog
%ZEF_ABOUT_DIALOG  Themed About window (replaces MATLAB msgbox).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_about_dialog
%
%   See also zef_ui_ready, zef_ui_theme.

existing = findall(groot, 'Type', 'figure', 'Name', 'ZEFFIRO Interface: About');
if ~isempty(existing)
    try
        figure(existing(1));
        return
    catch
    end
end

theme = zef_ui_theme();
f = uifigure( ...
    'Name', 'ZEFFIRO Interface: About', ...
    'Tag', 'zef_about', ...
    'WindowStyle', 'normal', ...
    'Resize', 'on', ...
    'Color', theme.color.bg, ...
    'Position', [120 120 460 340], ...
    'Visible', 'off');
try
    zef_window_manager('standalone', f);
catch
end

gl = uigridlayout(f, [8 1]);
gl.Tag = 'zef_ui_root';
gl.RowHeight = {36, 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 36};
gl.Padding = [22 18 22 18];
gl.RowSpacing = 8;
gl.BackgroundColor = theme.color.bg;

uilabel(gl, 'Text', 'Zeffiro Interface', ...
    'FontWeight', 'bold', 'FontSize', theme.font.sizeTitle, ...
    'FontColor', theme.color.text, 'HorizontalAlignment', 'center');
uilabel(gl, 'Text', 'Forward and inverse interface for complex geometries.', ...
    'FontColor', theme.color.text, 'HorizontalAlignment', 'center', ...
    'WordWrap', 'on');
uilabel(gl, 'Text', 'Zeffiro Interface V2', ...
    'FontColor', theme.color.textMuted, 'HorizontalAlignment', 'center');
uilabel(gl, 'Text', 'Lead contact: Sampsa Pursiainen', ...
    'FontColor', theme.color.text, 'HorizontalAlignment', 'center', ...
    'WordWrap', 'on');
contact = uieditfield(gl, 'text', ...
    'Value', 'sampsa.pursiainen@tuni.fi', ...
    'Editable', 'off', ...
    'HorizontalAlignment', 'center', ...
    'FontColor', theme.color.text, ...
    'BackgroundColor', theme.color.bg, ...
    'Tag', 'zef_about_contact');
try
    contact.Layout.Row = 5;
    contact.Layout.Column = 1;
catch
end
link = uibutton(gl, 'Text', 'github.com/sampsapursiainen/zeffiro_interface', ...
    'Tag', 'zef_about_link', ...
    'ButtonPushedFcn', @(src, ~) web('https://github.com/sampsapursiainen/zeffiro_interface', '-browser'));
try
    link.Layout.Row = 6;
    link.Layout.Column = 1;
    link.FontColor = theme.color.accent;
    link.BackgroundColor = theme.color.bg;
catch
end
uilabel(gl, 'Text', 'Copyright © 2018–2026 Sampsa Pursiainen & ZI Development Team', ...
    'FontColor', theme.color.textMuted, 'HorizontalAlignment', 'center', ...
    'WordWrap', 'on');
uilabel(gl, 'Text', 'Created using MATLAB. © 1984– The MathWorks, Inc.', ...
    'FontColor', theme.color.textMuted, 'HorizontalAlignment', 'center', ...
    'WordWrap', 'on');

brow = uigridlayout(gl, [1 3]);
brow.ColumnWidth = {'1x', 120, '1x'};
brow.Padding = [0 0 0 0];
brow.RowHeight = {28};
try
    brow.BackgroundColor = theme.color.bg;
catch
end
uilabel(brow, 'Text', '');
btn = uibutton(brow, 'Text', 'Close', 'Tag', 'zef_about_close', ...
    'ButtonPushedFcn', @(src, ~) close(ancestor(src, 'figure')));
try
    btn.Layout.Column = 2;
catch
end

try
    zef_ui_apply_theme(f, theme);
    zef_ui_polish_window(f, theme);
catch
end
try
    gl.BackgroundColor = theme.color.bg;
    brow.BackgroundColor = theme.color.bg;
catch
end
try
    btn.BackgroundColor = theme.color.primary;
    btn.FontColor = theme.color.primaryText;
catch
end
try
    setappdata(f, 'ZefUiThemed', true);
catch
end
try
    zef_ui_interact(f);
catch
end
try
    zef_ui_bind_min_size(f, 400, 300);
catch
end
try
    f.WindowKeyPressFcn = @(src, evt) local_key(src, evt);
catch
end
try
    zef_ui_place_window(f);
catch
end
f.Visible = 'on';
try
    zef_window_manager('raise', f);
catch
end

end

function local_key(src, evt)

key = '';
try
    if isstruct(evt) && isfield(evt, 'Key')
        key = char(evt.Key);
    end
catch
end
if any(strcmpi(key, {'escape', 'return', 'space'}))
    try
        close(ancestor(src, 'figure'));
    catch
        try
            close(src);
        catch
        end
    end
end

end
