function theme = zef_ui_theme(zef)
%ZEF_UI_THEME  Shared visual tokens for every Zeffiro window.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Palette matches the waitbar (cool gray surfaces, teal accent) so the
%   figure tool, tool windows, settings dialogs, and plugins read as one
%   product. Font size is at least 11 px even when the INI still says 8.
%
%   theme = zef_ui_theme
%   theme = zef_ui_theme(zef)
%
%   See also zef_ui_apply_theme, zef_waitbar.

if nargin < 1
    zef = struct();
    try
        zef = evalin('base', 'zef');
    catch
    end
end

font_size = 12;
if isstruct(zef) && isfield(zef, 'font_size') && ~isempty(zef.font_size)
    font_size = max(11, double(zef.font_size));
end

theme = struct();
theme.color.bg = [0.970 0.975 0.978];
theme.color.panel = [1.000 1.000 1.000];
theme.color.panelAlt = [0.955 0.962 0.966];
theme.color.text = [0.140 0.180 0.220];
theme.color.textMuted = [0.420 0.470 0.510];
theme.color.accent = [0.120 0.520 0.550];
theme.color.accentSoft = [0.820 0.870 0.880];
theme.color.button = [0.935 0.948 0.950];
theme.color.buttonText = [0.140 0.180 0.220];
theme.color.primary = [0.120 0.520 0.550];
theme.color.primaryText = [1.000 1.000 1.000];
theme.color.border = [0.820 0.850 0.860];
theme.color.inputBg = [1.000 1.000 1.000];
theme.color.axesBg = [0.985 0.988 0.990];
theme.color.header = [0.120 0.520 0.550];
theme.color.slider = [0.120 0.520 0.550];

theme.font.name = local_font_name();
theme.font.size = font_size;
theme.font.sizeSmall = max(10, font_size - 1);
theme.font.sizeTitle = font_size + 1;
theme.font.weight = 'normal';

theme.space.pad = 10;
theme.space.gap = 8;
theme.space.row = 22;
theme.space.btnH = 28;
% Java uicontrol sliders on macOS paint arrow buttons that clip when the
% Position height is below 16 px. Taller values only stretch the track.
theme.space.sliderH = 16;
theme.space.sliderGap = 2;
theme.space.popupH = 22;
theme.space.rowGap = 4;
theme.space.labelW = 118;
theme.space.sectionGap = 8;
theme.space.sidebarW = 292;
theme.space.bottomH = 168;
theme.space.editW = 52;
theme.space.tableRow = 28;
theme.space.minWinW = 720;
theme.space.minWinH = 540;

end

function name = local_font_name()

name = 'Helvetica Neue';
try
    fonts = listfonts;
    if any(strcmp(fonts, 'Helvetica Neue'))
        name = 'Helvetica Neue';
    elseif any(strcmp(fonts, 'Helvetica'))
        name = 'Helvetica';
    elseif any(strcmp(fonts, '.AppleSystemUIFont'))
        name = '.AppleSystemUIFont';
    else
        name = get(groot, 'defaultUicontrolFontName');
    end
catch
    name = 'Helvetica';
end

end
