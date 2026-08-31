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
if isappdata(fig, 'ZefGuideForm')
    try
        zef_layout_guide_form(fig);
    catch
    end
    return
end
root = findall(fig, 'Tag', 'zef_ui_root');
if isempty(root)
    try
        fcn = getappdata(fig, 'ZefPixelResize');
        if isa(fcn, 'function_handle')
            fcn(fig);
        end
    catch
    end
    return
end
root = root(1);
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
    fig.AutoResizeChildren = 'off';
catch
end
try
    root.Position = [1 1 max(1, W) max(1, H)];
catch
end

name = '';
try
    name = char(fig.Name);
catch
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
        footer = max(140, min(200, round(0.22 * H)));
        if H < 520
            footer = 120;
        end
        if numel(root.RowHeight) >= 3
            root.RowHeight = {header, '1x', footer};
        end
        cols = findall(fig, 'Tag', 'zef_seg_cols');
        hdr = findall(fig, 'Tag', 'zef_seg_header');
        if ~isempty(hdr)
            if W < 1080
                hdr(1).ColumnWidth = {'fit', '1x', 168, 'fit', 'fit', 160};
            else
                hdr(1).ColumnWidth = {'fit', '1x', 188, 'fit', 'fit', 176};
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
            left = max(300, min(340, round(0.32 * W)));
            root.ColumnWidth = {left, '1x'};
        end
        right = findall(fig, 'Tag', 'zef_mesh_right');
        if ~isempty(right)
            if H < 540
                right(1).RowHeight = {'1x', 80, 36};
            else
                right(1).RowHeight = {'1x', 96, 36};
            end
        end
        tbl = findall(fig, 'Tag', 'h_forward_simulation_table');
        if ~isempty(tbl)
            try
                tbl(1).ColumnWidth = {200, '2.8x', '2.2x'};
            catch
            end
        end
    elseif contains(lower(name), 'nse tool')
        sz = [1180, 951];
        if isappdata(fig, 'ZefNseContent')
            tmp = getappdata(fig, 'ZefNseContent');
            if numel(tmp) >= 2
                sz = tmp;
            end
        end
        try
            if W >= sz(1) - 8
                root.ColumnWidth = {'1x'};
            else
                root.ColumnWidth = {sz(1)};
            end
            if H >= sz(2) - 8
                root.RowHeight = {'1x'};
                root.Scrollable = 'off';
            else
                root.RowHeight = {sz(2)};
                root.Scrollable = 'on';
            end
        catch
        end
    elseif isappdata(fig, 'ZefTableFitH') && numel(root.RowHeight) >= 2
        try
            fit_h = getappdata(fig, 'ZefTableFitH');
            pad = 24;
            try
                pad = sum(root.Padding([2 4])) + root.RowSpacing + 56;
            catch
            end
            if H > fit_h + pad + 24
                root.RowHeight = {'1x', 56};
            else
                root.RowHeight = {fit_h, 56};
            end
        catch
        end
    elseif contains(name, 'Filter tool')
        if numel(root.ColumnWidth) >= 2
            root.ColumnWidth = {'1x', '1x'};
        end
        leftg = findall(fig, 'Tag', 'zef_filter_left');
        if ~isempty(leftg) && H < 720
            leftg(1).RowHeight = {20, '1x', 28, 30, 30, 30, 20, '1x', 32, 36, 36};
        elseif ~isempty(leftg)
            leftg(1).RowHeight = {22, '1x', 32, 32, 32, 32, 22, '1x', 32, 36, 36};
        end
        rightg = findall(fig, 'Tag', 'zef_filter_right');
        if ~isempty(rightg) && H < 720
            rightg(1).RowHeight = {34, 34, 30, 24, 24, 24, 24, 30, 30, 30, 20, '1x', 30, 30, 34, 30};
        elseif ~isempty(rightg)
            rightg(1).RowHeight = {36, 36, 32, 26, 26, 26, 26, 32, 32, 32, 22, '1x', 32, 32, 36, 32};
        end
    elseif contains(lower(name), 'find synthetic source') ...
            && ~contains(lower(name), 'legacy')
        mid = findall(fig, 'Tag', 'zef_fss_tables');
        if ~isempty(mid)
            if W < 560
                mid(1).ColumnWidth = {120, '1x'};
            else
                mid(1).ColumnWidth = {160, '1x'};
            end
        end
        if numel(root.RowHeight) >= 6
            root.RowHeight = {36, '1x', 32, 28, 36, 36};
        end
    end
catch
end

try
    tables = findall(fig, 'Type', 'uitable');
    for i = 1:numel(tables)
        zef_ui_fit_table(tables(i));
    end
catch
end
try
    if contains(lower(name), 'find synthetic source') ...
            && ~contains(lower(name), 'legacy')
        mid = findall(fig, 'Tag', 'zef_fss_tables');
        if ~isempty(mid)
            tbls = findall(mid(1), 'Type', 'uitable');
            xs = inf(numel(tbls), 1);
            for i = 1:numel(tbls)
                try
                    gp = getpixelposition(tbls(i), true);
                    xs(i) = gp(1);
                catch
                end
            end
            [~, xo] = sort(xs);
            if numel(tbls) >= 1
                tbls(xo(1)).ColumnWidth = {'1x'};
            end
            if numel(tbls) >= 2
                tbls(xo(end)).ColumnWidth = {'1.3x', '1x'};
            end
        end
    end
catch
end
try
    if contains(name, 'Mesh tool') && ~contains(name, 'visualization')
        tbl = findall(fig, 'Tag', 'h_forward_simulation_table');
        if ~isempty(tbl)
            tbl(1).ColumnWidth = {200, '2.8x', '2.2x'};
        end
    end
catch
end

end
