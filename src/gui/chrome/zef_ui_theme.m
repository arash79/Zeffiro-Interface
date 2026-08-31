function theme = zef_ui_theme(zef)
%ZEF_UI_THEME  Shared visual tokens for every Zeffiro window.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Cool-gray surfaces and a restrained teal accent. Light is the default
%   product look; zef.ui_color_mode = 'dark' selects the dark palette.
%   Font size is at least 11 px even when the INI still says 8. Shell
%   geometry (nav/header/footer) lives in theme.space.* so every window
%   can share the same proportions.
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

mode = 'light';
if isstruct(zef) && isfield(zef, 'ui_color_mode') && ~isempty(zef.ui_color_mode)
    mode = lower(char(string(zef.ui_color_mode)));
end
if ~ismember(mode, {'light', 'dark'})
    mode = 'light';
end

theme = struct();
theme.mode = mode;
if strcmp(mode, 'dark')
    theme.color.bg = [0.118 0.133 0.145];
    theme.color.panel = [0.160 0.176 0.188];
    theme.color.panelAlt = [0.145 0.160 0.172];
    theme.color.text = [0.910 0.925 0.935];
    theme.color.textMuted = [0.620 0.660 0.690];
    theme.color.accent = [0.220 0.690 0.710];
    theme.color.accentSoft = [0.180 0.280 0.290];
    theme.color.button = [0.200 0.220 0.232];
    theme.color.buttonText = [0.910 0.925 0.935];
    theme.color.primary = [0.120 0.520 0.550];
    theme.color.primaryText = [1.000 1.000 1.000];
    theme.color.border = [0.280 0.310 0.325];
    theme.color.inputBg = [0.145 0.158 0.168];
    theme.color.axesBg = [0.145 0.158 0.168];
    theme.color.header = [0.320 0.780 0.790];
    theme.color.slider = [0.220 0.690 0.710];
    theme.color.navBg = [0.145 0.158 0.168];
    theme.color.headerBg = [0.145 0.158 0.168];
    theme.color.footerBg = [0.145 0.158 0.168];
    theme.color.navHover = [0.185 0.205 0.218];
    theme.color.navActive = [0.180 0.280 0.290];
    theme.color.navIcon = [0.620 0.780 0.790];
    theme.color.ready = [0.250 0.720 0.430];
    theme.color.workspace = [1.000 1.000 1.000] * 0.18;
    theme.color.disabled = [0.420 0.450 0.470];
    theme.color.tableRow = [0.160 0.176 0.188];
    theme.color.tableAlt = [0.145 0.160 0.172];
    theme.color.tableHeader = [0.180 0.198 0.210];
    theme.color.selection = [0.180 0.280 0.290];
    theme.color.hover = [0.185 0.205 0.218];
    theme.color.warning = [0.860 0.620 0.220];
    theme.color.danger = [0.780 0.280 0.280];
else
    theme.color.bg = [0.965 0.970 0.974];
    theme.color.panel = [1.000 1.000 1.000];
    theme.color.panelAlt = [0.955 0.962 0.966];
    theme.color.text = [0.145 0.175 0.210];
    theme.color.textMuted = [0.380 0.425 0.460];
    theme.color.accent = [0.120 0.520 0.550];
    theme.color.accentSoft = [0.820 0.870 0.880];
    theme.color.button = [1.000 1.000 1.000];
    theme.color.buttonText = [0.145 0.175 0.210];
    theme.color.primary = [0.120 0.520 0.550];
    theme.color.primaryText = [1.000 1.000 1.000];
    theme.color.border = [0.820 0.848 0.858];
    theme.color.inputBg = [1.000 1.000 1.000];
    theme.color.axesBg = [1.000 1.000 1.000];
    theme.color.header = [0.120 0.520 0.550];
    theme.color.slider = [0.120 0.520 0.550];
    theme.color.navBg = [1.000 1.000 1.000];
    theme.color.headerBg = [1.000 1.000 1.000];
    theme.color.footerBg = [0.965 0.970 0.974];
    theme.color.navHover = [0.820 0.870 0.880];
    theme.color.navActive = [0.820 0.870 0.880];
    theme.color.navIcon = [0.220 0.420 0.450];
    theme.color.ready = [0.180 0.620 0.360];
    theme.color.workspace = [1.000 1.000 1.000];
    theme.color.disabled = [0.720 0.745 0.760];
    theme.color.tableRow = [1.000 1.000 1.000];
    theme.color.tableAlt = [0.948 0.956 0.960];
    theme.color.tableHeader = [0.955 0.962 0.966];
    theme.color.selection = [0.820 0.870 0.880];
    theme.color.hover = [0.910 0.930 0.932];
    theme.color.warning = [0.780 0.520 0.120];
    theme.color.danger = [0.720 0.220 0.220];
end

theme.color.surface = theme.color.panel;
theme.color.surfaceSecondary = theme.color.panelAlt;
theme.color.textPrimary = theme.color.text;
theme.color.textSecondary = theme.color.textMuted;
theme.color.error = theme.color.danger;
theme.color.success = theme.color.ready;
if strcmp(mode, 'dark')
    theme.color.accentHover = [0.260 0.740 0.760];
    theme.color.accentPressed = [0.090 0.400 0.430];
else
    theme.color.accentHover = [0.100 0.460 0.490];
    theme.color.accentPressed = [0.080 0.380 0.410];
end

theme.font.name = local_font_name();
theme.font.size = font_size;
theme.font.sizeSmall = max(10, font_size - 1);
theme.font.sizeTitle = font_size + 1;
theme.font.weight = 'normal';

theme.space.pad = 10;
theme.space.gap = 8;
theme.space.row = 22;
theme.space.btnH = 26;
% Java uicontrol sliders on macOS paint arrow buttons that clip when the
% Position height is below 16 px. Taller values only stretch the track.
theme.space.sliderH = 16;
theme.space.sliderGap = 3;
theme.space.popupH = 22;
theme.space.rowGap = 4;
theme.space.labelW = 110;
theme.space.sectionGap = 8;
theme.space.sidebarW = 240;
theme.space.bottomH = 168;
theme.space.statusH = 88;
theme.space.editW = 48;
theme.space.tableRow = 28;
theme.space.minWinW = 720;
theme.space.minWinH = 540;
theme.space.navW = 168;
theme.space.navWCompact = 52;
theme.space.headerH = 40;
theme.space.footerH = 22;
theme.space.tabH = 28;
theme.space.toolbarH = 36;
theme.space.navItemH = 32;
theme.space.cardGap = 12;
theme.space.headerGap = 0;
theme.space.cardRadius = 12;
theme.space.btnRadius = 6;
theme.space.flyoutW = 268;
theme.space.shellMinW = 980;
theme.space.shellMinH = 620;
theme.space.shellDefW = 1200;
theme.space.shellDefH = 646;

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
