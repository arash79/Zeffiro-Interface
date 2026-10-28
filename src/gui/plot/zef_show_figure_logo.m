function zef_show_figure_logo(target, refresh_layout)
%ZEF_SHOW_FIGURE_LOGO  Clear the figure axes and draw the Zeffiro logo.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_show_figure_logo(axes_handle)
%   zef_show_figure_logo(axes_handle, true)
%   zef_show_figure_logo(zef)
%   zef_show_figure_logo(zef, true)
%   zef_show_figure_logo(src, event)   % Logo button callback
%
%   The one-argument form draws the logo and leaves layout to the caller.
%   Pass true, or invoke it as a button callback, to run
%   zef_figure_tool_layout afterwards. A struct uses zef.h_axes1.
%   A control uses the axes of its figure.
%
%   See also zef_figure_tool, zef_figure_tool_layout, zef_load.

if nargin < 1 || isempty(target)
    return
end
if nargin < 2
    refresh_layout = false;
elseif ~(islogical(refresh_layout) || isnumeric(refresh_layout))
    refresh_layout = true;
else
    refresh_layout = logical(refresh_layout(1));
end

h_axes = local_axes(target);
if isempty(h_axes)
    return
end

bg = [1 1 1];
try
    th = zef_ui_theme();
    bg = th.color.axesBg;
catch
end

img = [];
try
    img = local_logo_image(bg);
catch
    try
        img = imread('zeffiro_interface_compass.png', 'BackgroundColor', bg);
    catch
    end
end
if isempty(img)
    return
end

cla(h_axes, 'reset');
try
    if isappdata(h_axes, 'ZefHasVolumePlot')
        rmappdata(h_axes, 'ZefHasVolumePlot');
    end
    if isappdata(h_axes, 'ZefAxesDressed')
        rmappdata(h_axes, 'ZefAxesDressed');
    end
    if isappdata(h_axes, 'ZefLogoSlot')
        rmappdata(h_axes, 'ZefLogoSlot');
    end
catch
end
try
    h_fig_logo = ancestor(h_axes, 'figure');
    zef_figure_interact(h_fig_logo, 'set', 'none');
    zef_figure_interact(h_fig_logo, 'forget_home');
catch
end
h_axes.Tag = 'axes1';
imh = image(h_axes, img);
try
    imh.Tag = 'zef_logo_img';
    setappdata(imh, 'ZefLogoSrc', im2double(img));
catch
end
h_axes.YDir = 'reverse';
h_axes.XTick = [];
h_axes.YTick = [];
h_axes.Box = 'off';
h_axes.Color = bg;
try
    h_axes.XColor = 'none';
    h_axes.YColor = 'none';
catch
end
try
    disableDefaultInteractivity(h_axes);
catch
end
try
    if isempty(h_axes.Toolbar)
        axtoolbar(h_axes, {'restoreview'});
    end
catch
end
try
    h_axes.Toolbar.Visible = 'off';
catch
end
h_axes.Visible = 'on';
try
    tt = findall(ancestor(h_axes, 'figure'), 'Tag', 'time_text');
    if ~isempty(tt) && isvalid(tt(1))
        set(tt(1), 'String', '', 'Visible', 'off');
    end
catch
end
try
    delete(h_axes.Legend);
    delete(h_axes.XLabel);
    delete(h_axes.YLabel);
    delete(h_axes.ZLabel);
catch
end

if refresh_layout
    try
        zef_figure_tool_layout(ancestor(h_axes, 'figure'));
    catch
    end
end
h_axes.Tag = 'axes1';

end

function h_axes = local_axes(target)

h_axes = [];
if isstruct(target)
    if isfield(target, 'h_axes1') && isgraphics(target.h_axes1) && isvalid(target.h_axes1)
        h_axes = target.h_axes1(1);
    end
    return
end
if ~isgraphics(target)
    return
end
if strcmp(get(target, 'Type'), 'axes')
    h_axes = target;
    return
end
h_fig = ancestor(target, 'figure');
if isempty(h_fig)
    return
end
h_axes = zef_ui_axes(h_fig);
if isempty(h_axes) || ~isvalid(h_axes(1))
    h_axes = [];
    return
end
h_axes = h_axes(1);

end

function img = local_logo_image(bg)

persistent logo_bg logo_img
bg = reshape(double(bg(1:3)), 1, 3);
if ~isempty(logo_img) && isequal(logo_bg, bg)
    img = logo_img;
    return
end

fname = 'zeffiro_interface_compass.png';
alpha = [];
try
    [img, ~, alpha] = imread(fname);
catch
    img = imread(fname, 'BackgroundColor', bg);
end
if size(img, 3) == 1
    img = repmat(img, [1 1 3]);
end
if ~isempty(alpha)
    a = im2double(alpha);
    if size(a, 3) > 1
        a = a(:, :, 1);
    end
    bg8 = reshape(double(uint8(max(0, min(255, round(255 * bg))))), 1, 1, 3);
    img = uint8(double(img) .* a + bg8 .* (1 - a));
end
tol = 14;
bg8 = reshape(double(uint8(max(0, min(255, round(255 * bg))))), 1, 1, 3);
mask = max(abs(double(img) - bg8), [], 3) > tol;
white = max(abs(double(img) - 255), [], 3) < 8;
mask = mask & ~white;
if ~any(mask(:))
    logo_bg = bg;
    logo_img = img;
    return
end
[r, c] = find(mask);
pad = 12;
r1 = max(1, min(r) - pad);
r2 = min(size(img, 1), max(r) + pad);
c1 = max(1, min(c) - pad);
c2 = min(size(img, 2), max(c) + pad);
img = img(r1:r2, c1:c2, :);
bg8 = uint8(max(0, min(255, round(255 * bg))));
near_white = max(abs(double(img) - 255), [], 3) < 28;
for k = 1:size(img, 3)
    ch = img(:, :, k);
    ch(near_white) = bg8(k);
    img(:, :, k) = ch;
end
logo_bg = bg;
logo_img = img;

end
