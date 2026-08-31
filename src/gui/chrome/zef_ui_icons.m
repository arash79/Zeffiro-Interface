function out = zef_ui_icons(name, sz, fg, bg)
%ZEF_UI_ICONS  Load a themed CData icon from the shared line-icon family.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   cdata = zef_ui_icons(name)
%   cdata = zef_ui_icons(name, sz, fg, bg)
%   folder = zef_ui_icons('folder')
%
%   PNG alpha is composited onto bg and the opaque ink is tinted with fg
%   so the same assets work in light and dark themes.
%
%   See also zef_ui_shell, zef_ui_theme.

if nargin < 1 || isempty(name)
    name = 'folder';
end
name = lower(char(string(name)));
if nargin < 2 || isempty(sz)
    sz = 20;
end
if nargin < 3 || isempty(fg)
    fg = [0.145 0.175 0.210];
    try
        th = zef_ui_theme();
        fg = th.color.text;
    catch
    end
end
if nargin < 4 || isempty(bg)
    bg = [0.945 0.952 0.956];
    try
        th = zef_ui_theme();
        bg = th.color.panel;
    catch
    end
end

if strcmp(name, 'folder')
    out = local_folder();
    return
end

file = local_file(name);
out = [];
if isempty(file)
    return
end
try
    [img, ~, alpha] = imread(file);
catch
    return
end
if size(img, 3) == 1
    img = repmat(img, [1 1 3]);
end
img = im2double(img(:, :, 1:min(3, size(img, 3))));
if isempty(alpha)
    alpha = max(abs(img - 1), [], 3) > 0.08;
else
    alpha = im2double(alpha);
    if size(alpha, 3) > 1
        alpha = alpha(:, :, 1);
    end
end
fg = reshape(double(fg(1:3)), 1, 1, 3);
bg = reshape(double(bg(1:3)), 1, 1, 3);
if ismember(name, {'gizmo'})
    rgb = bg .* (1 - alpha) + img .* alpha;
else
    rgb = bg .* (1 - alpha) + fg .* alpha;
end
if sz > 0 && (size(rgb, 1) ~= sz || size(rgb, 2) ~= sz)
    try
        a2 = imresize(alpha, [sz sz], 'bilinear');
        a2 = min(1, a2 * 1.22);
        if ismember(name, {'gizmo'})
            img2 = imresize(img, [sz sz], 'bilinear');
            bg2 = repmat(bg, sz, sz);
            rgb = bg2 .* (1 - a2) + img2 .* a2;
        else
            bg2 = repmat(bg, sz, sz);
            fg2 = repmat(fg, sz, sz);
            rgb = bg2 .* (1 - a2) + fg2 .* a2;
        end
    catch
        try
            rgb = imresize(rgb, [sz sz], 'bilinear');
        catch
        end
    end
end
out = max(0, min(1, rgb));

end

function folder = local_folder()

root = fileparts(which('zeffiro_interface'));
if isempty(root)
    root = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
end
folder = fullfile(root, 'assets', 'fig', 'ui');

end

function file = local_file(name)

folder = local_folder();
cands = { ...
    fullfile(folder, [name '.png']), ...
    [name '.png']};
file = '';
for i = 1:numel(cands)
    if exist(cands{i}, 'file') == 2
        file = cands{i};
        return
    end
    w = which(cands{i});
    if ~isempty(w)
        file = w;
        return
    end
end

end
