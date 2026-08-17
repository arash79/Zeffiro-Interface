function zef_ui_adapt_grid(fig)
%ZEF_UI_ADAPT_GRID  Tune grid proportions from the current window size.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Nested 'fit' rows keep controls at their natural size. Flexible
%   bands (lists, tables, notes) absorb leftover height so shrinking
%   does not clip the control stack and growing does not leave an
%   empty pocket beside a packed column.
%
%   See also zef_ui_bind_min_size.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
root = findall(fig, 'Tag', 'zef_ui_root');
if isempty(root)
    return
end
root = root(1);
name = '';
try
    name = char(fig.Name);
catch
end

try
    orig = fig.Units;
    fig.Units = 'pixels';
    H = fig.Position(4);
    W = fig.Position(3);
    fig.Units = orig;
catch
    return
end

try
    if contains(name, 'Mesh visualization')
        if numel(root.RowHeight) >= 2
            bottom_share = '0.28x';
            if H < 580
                bottom_share = '0.26x';
            elseif H > 720
                bottom_share = '0.32x';
            end
            root.RowHeight = {'1x', bottom_share};
        end
        leftg = findall(fig, 'Tag', 'zef_mv_left');
        if ~isempty(leftg)
            leftg(1).RowHeight = {'fit', 'fit', '1x'};
        end
        clip = findall(fig, 'Tag', 'zef_mv_clip');
        actions = findall(fig, 'Tag', 'zef_mv_actions');
        scene = findall(fig, 'Tag', 'zef_mv_scene');
        if ~isempty(clip)
            clip(1).RowHeight = {28, 28, 28, 28};
        end
        if H < 590
            if ~isempty(actions)
                actions(1).RowHeight = {26, 26, 26};
            end
            if ~isempty(scene)
                scene(1).RowHeight = {20, 20, 20, 24};
            end
        else
            if ~isempty(actions)
                actions(1).RowHeight = {28, 28, 28};
            end
            if ~isempty(scene)
                scene(1).RowHeight = {22, 22, 22, 26};
            end
        end
    elseif contains(name, 'Segmentation')
        header = 68;
        footer = max(100, min(128, round(0.18 * H)));
        if H < 520
            footer = 96;
        end
        if numel(root.RowHeight) >= 3
            root.RowHeight = {header, '1x', footer};
        end
        cols = findall(fig, 'Tag', 'zef_seg_cols');
        hdr = findall(fig, 'Tag', 'zef_seg_header');
        if ~isempty(hdr)
            if W < 1080
                hdr(1).ColumnWidth = {'fit', '1x', 136, 'fit', 'fit', 148};
            else
                hdr(1).ColumnWidth = {'fit', '1x', 148, 'fit', 'fit', 168};
            end
        end
        if ~isempty(cols)
            if W < 1080
                cols(1).ColumnWidth = {'1.55x', '1.45x', '1.00x'};
            elseif W > 1400
                cols(1).ColumnWidth = {'1.85x', '1.22x', '0.88x'};
            else
                cols(1).ColumnWidth = {'1.80x', '1.24x', '0.90x'};
            end
        end
        foot = findall(fig, 'Tag', 'zef_seg_foot');
        if ~isempty(foot) && ~isempty(cols)
            foot(1).ColumnWidth = cols(1).ColumnWidth;
        end
        mid = findall(fig, 'Tag', 'zef_seg_mid');
        if ~isempty(mid)
            if H < 540
                mid(1).RowHeight = {'1.05x', 22, '1x'};
            else
                mid(1).RowHeight = {'1x', 22, '1x'};
            end
        end
    elseif contains(name, 'Mesh tool') && ~contains(name, 'visualization')
        if numel(root.ColumnWidth) >= 2
            left = max(320, min(360, round(0.38 * W)));
            root.ColumnWidth = {left, '1x'};
        end
        right = findall(fig, 'Tag', 'zef_mesh_right');
        if ~isempty(right)
            if H < 500
                right(1).RowHeight = {'1.7x', '0.8x', 36};
            else
                right(1).RowHeight = {'1.8x', '0.70x', 36};
            end
        end
    end
catch
end

try
    drawnow nocallbacks;
catch
    try
        drawnow;
    catch
    end
end

try
    tables = findall(fig, 'Type', 'uitable');
    for i = 1:numel(tables)
        zef_ui_fit_table(tables(i));
    end
catch
end

end
