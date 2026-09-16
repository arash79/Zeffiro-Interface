function zef_ui_blend_logo(obj, theme)
%ZEF_UI_BLEND_LOGO  Composite a Zeffiro logo onto the widget background.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Compass PNGs ship with a transparent (or keyed black/white) plate.
%   uiimage draws that transparency on black, so this helper reads the
%   alpha, tints gray wordmark ink to the theme text color, and writes
%   an opaque RGB ImageSource.
%
%   zef_ui_blend_logo(obj)
%   zef_ui_blend_logo(obj, theme)
%
%   See also zef_ui_apply_theme, zef_layout_segmentation_tool.

if nargin < 1 || isempty(obj) || ~isgraphics(obj) || ~isvalid(obj)
    return
end
if nargin < 2 || isempty(theme)
    theme = zef_ui_theme();
end

bg = theme.color.bg;
try
    if isprop(obj, 'BackgroundColor') && isnumeric(obj.BackgroundColor) ...
            && numel(obj.BackgroundColor) >= 3
        bg = double(obj.BackgroundColor(1:3));
    end
catch
end
try
    par = obj.Parent;
    if ~isempty(par) && isgraphics(par) && isprop(par, 'BackgroundColor') ...
            && isnumeric(par.BackgroundColor) && numel(par.BackgroundColor) >= 3
        bg = double(par.BackgroundColor(1:3));
    end
catch
end
fg = theme.color.text;
try
    fg = double(theme.color.text(1:3));
catch
end

file = local_logo_file(obj);
if isempty(file)
    try
        obj.BackgroundColor = bg;
        obj.ScaleMethod = 'fit';
    catch
    end
    return
end

key = [round(bg * 1000), round(fg * 1000)];
try
    prev = getappdata(obj, 'ZefLogoKey');
    src_now = obj.ImageSource;
    if isequal(prev, key) && isnumeric(src_now) && ~isempty(src_now)
        obj.BackgroundColor = bg;
        return
    end
catch
end

[rgb, alpha] = local_read(file);
if isempty(rgb)
    return
end
out = local_composite(rgb, alpha, bg, fg);
try
    setappdata(obj, 'ZefLogoOriginal', file);
    setappdata(obj, 'ZefLogoKey', key);
catch
end
try
    obj.ImageSource = uint8(max(0, min(255, round(out * 255))));
    obj.BackgroundColor = bg;
    obj.ScaleMethod = 'fit';
    obj.VerticalAlignment = 'center';
catch
end

end

function file = local_logo_file(obj)

file = '';
try
    orig = getappdata(obj, 'ZefLogoOriginal');
    if (ischar(orig) || isstring(orig)) && strlength(orig) > 0 ...
            && exist(char(orig), 'file') == 2
        file = char(orig);
        return
    end
catch
end
src = [];
try
    src = obj.ImageSource;
catch
end
if ischar(src) || isstring(src)
    s = char(src);
    if exist(s, 'file') == 2
        file = s;
        return
    end
    hit = which(s);
    if ~isempty(hit) && exist(hit, 'file') == 2
        file = hit;
        return
    end
end
tag = '';
try
    tag = lower(char(obj.Tag));
catch
end
is_logo = contains(tag, 'logo') || strcmp(tag, 'h_axes2');
if ~is_logo && (ischar(src) || isstring(src))
    is_logo = contains(lower(char(src)), 'zeffiro') || contains(lower(char(src)), 'logo');
end
if ~is_logo
    return
end
cands = {which('zeffiro_logo_compass.png')};
try
    root = fileparts(which('zeffiro_interface'));
    cands{end+1} = fullfile(root, 'assets', 'fig', 'zeffiro_logo_compass.png'); %#ok<AGROW>
catch
end
try
    here = fileparts(mfilename('fullpath'));
    root = fileparts(fileparts(fileparts(here)));
    cands{end+1} = fullfile(root, 'assets', 'fig', 'zeffiro_logo_compass.png'); %#ok<AGROW>
catch
end
for i = 1:numel(cands)
    if ~isempty(cands{i}) && exist(cands{i}, 'file') == 2
        file = cands{i};
        return
    end
end

end

function [rgb, alpha] = local_read(file)

rgb = [];
alpha = [];
img = [];
a = [];
try
    [img, ~, a] = imread(file);
catch
    try
        img = imread(file);
    catch
        return
    end
end
if isempty(img) || size(img, 1) < 2 || size(img, 2) < 2
    return
end
rgb = local_to_double(img);
if size(rgb, 3) >= 4
    a = rgb(:, :, 4);
    rgb = rgb(:, :, 1:3);
elseif size(rgb, 3) == 1
    rgb = repmat(rgb, 1, 1, 3);
end
if isempty(a)
    lum = mean(rgb, 3);
    mx = max(rgb, [], 3);
    mn = min(rgb, [], 3);
    sat = mx - mn;
    alpha = double(~((lum < 0.09 & sat < 0.11) | (lum > 0.95 & sat < 0.07)));
else
    alpha = local_to_double(a);
    if size(alpha, 3) > 1
        alpha = alpha(:, :, 1);
    end
end

end

function out = local_composite(rgb, alpha, bg, fg)

bg = reshape(double(bg(1:3)), 1, 1, 3);
fg = reshape(double(fg(1:3)), 1, 1, 3);
if size(alpha, 3) > 1
    alpha = alpha(:, :, 1);
end
mx = max(rgb, [], 3);
mn = min(rgb, [], 3);
sat = mx - mn;
lum = mean(rgb, 3);
gray = alpha > 0.05 & sat < 0.11 & lum >= 0.12 & lum <= 0.82;
for k = 1:3
    ch = rgb(:, :, k);
    ch(gray) = fg(k);
    rgb(:, :, k) = ch;
end
am = repmat(alpha, 1, 1, 3);
out = rgb .* am + repmat(bg, size(rgb, 1), size(rgb, 2)) .* (1 - am);
out = max(0, min(1, out));

end

function out = local_to_double(in)

out = [];
if isempty(in)
    return
end
try
    out = im2double(in);
    return
catch
end
out = double(in);
if max(out(:)) > 1.5
    out = out / 255;
end

end
