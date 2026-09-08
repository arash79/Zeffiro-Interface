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
            root.RowHeight = {'fit', '1x'};
        end
        leftg = findall(fig, 'Tag', 'zef_mv_left');
        if ~isempty(leftg)
            if numel(leftg(1).RowHeight) >= 4
                leftg(1).RowHeight = {'fit', 'fit', 'fit', '1x'};
            else
                leftg(1).RowHeight = {'fit', 'fit', '1x'};
            end
        end
        clip = findall(fig, 'Tag', 'zef_mv_clip');
        actions = findall(fig, 'Tag', 'zef_mv_actions');
        scene = findall(fig, 'Tag', 'zef_mv_scene');
        viewg = findall(fig, 'Tag', 'zef_mv_view');
        if ~isempty(viewg)
            viewg(1).RowHeight = repmat({26}, 1, numel(viewg(1).RowHeight));
        end
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
        header = 56;
        footer = max(120, min(168, round(0.18 * H)));
        if H < 520
            footer = 108;
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
            if numel(right(1).RowHeight) >= 4
                if H < 540
                    right(1).RowHeight = {20, 140, '1x', 36};
                elseif H > 700
                    right(1).RowHeight = {22, 260, '1x', 36};
                else
                    right(1).RowHeight = {22, 200, '1x', 36};
                end
            elseif H < 540
                right(1).RowHeight = {140, '1x', 36};
            else
                right(1).RowHeight = {200, '1x', 36};
            end
        end
        tbl = findall(fig, 'Tag', 'h_forward_simulation_table');
        if ~isempty(tbl)
            try
                tbl(1).ColumnWidth = {220, '2.6x', '2.0x'};
            catch
            end
        end
    elseif contains(lower(name), 'databank') || contains(lower(name), 'data bank')
        if numel(root.ColumnWidth) >= 2
            left = max(200, min(260, round(0.22 * W)));
            root.ColumnWidth = {left, '1x'};
        end
        top = findall(fig, 'Tag', 'zef_db_top');
        if ~isempty(top)
            if W < 880
                top(1).ColumnWidth = {'1x', '1x', '1.5x'};
            else
                top(1).ColumnWidth = {'1.05x', '1x', '1.4x'};
            end
        end
    elseif contains(lower(name), 'nse tool')
        body = findall(fig, 'Tag', 'zef_nse_body');
        if ~isempty(body)
            if W < 1020
                body(1).ColumnWidth = {'1x', '1x', 280};
            else
                body(1).ColumnWidth = {'1x', '1x', 320};
            end
        end
        try
            root.RowHeight = {'1x'};
            root.ColumnWidth = {'1x'};
            root.Scrollable = 'on';
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
        if ~isempty(leftg)
            if H < 560
                leftg(1).RowHeight = {20, '1x', 64, 20, 112, 32};
            else
                leftg(1).RowHeight = {22, '1x', 72, 22, 140, 36};
            end
        end
        rightg = findall(fig, 'Tag', 'zef_filter_right');
        if ~isempty(rightg)
            if H < 560
                rightg(1).RowHeight = {32, 24, 24, 24, 24, 28, 20, '1x', 32, 32};
            else
                rightg(1).RowHeight = {36, 26, 26, 26, 26, 32, 22, '1x', 36, 36};
            end
        end
    elseif contains(lower(name), 'source tree')
        if numel(root.RowHeight) >= 4
            sig_h = 72;
            if H < 600
                sig_h = 64;
            end
            try
                rh = root.RowHeight;
                if numel(rh) >= 3
                    rh{3} = sig_h;
                    rh{4} = 40;
                    root.RowHeight = rh;
                end
            catch
            end
        end
    elseif contains(lower(name), 'leadfield processing') ...
            || contains(lower(name), 'lead field processing') ...
            || contains(lower(name), 'reconstruction tool')
        if numel(root.RowHeight) >= 6
            cur_h = 88;
            if H < 480
                cur_h = 72;
            end
            try
                rh = root.RowHeight;
                rh{2} = cur_h;
                rh{3} = 36;
                rh{6} = 44;
                root.RowHeight = rh;
            catch
            end
        end
        foot = findall(fig, 'Tag', 'zef_bank_foot');
        if ~isempty(foot)
            try
                n_col = numel(foot(1).ColumnWidth);
                if contains(lower(name), 'reconstruction')
                    foot(1).ColumnWidth = {'1x', 'fit', '1x'};
                elseif W < 860 && n_col >= 11
                    foot(1).ColumnWidth = {'1x', 92, 'fit', 'fit', 'fit', 64, 'fit', 64, 'fit', 96, '1x'};
                elseif W < 860 && n_col >= 10
                    foot(1).ColumnWidth = {'1x', 92, 'fit', 'fit', 'fit', 64, 'fit', 64, 96, '1x'};
                elseif n_col >= 11
                    foot(1).ColumnWidth = {'1x', 104, 'fit', 'fit', 'fit', 72, 'fit', 72, 'fit', 104, '1x'};
                elseif n_col >= 10
                    foot(1).ColumnWidth = {'1x', 104, 'fit', 'fit', 'fit', 72, 'fit', 72, 104, '1x'};
                end
            catch
            end
        end
        cur = findall(fig, 'Tag', 'zef_bank_cur');
        if ~isempty(cur)
            try
                n_btn = numel(findall(cur(1), 'Type', 'uibutton'));
                n_btn = max(1, n_btn);
                bw = 104;
                if W < 720
                    bw = 92;
                end
                cur(1).ColumnWidth = [{'1x'}, repmat({bw}, 1, n_btn), {'1x'}];
            catch
            end
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

local_reflow(fig);

end

function local_reflow(fig)

gs = findall(fig, 'Type', 'uigridlayout');
for i = 1:numel(gs)
    try
        cw = gs(i).ColumnWidth;
        if ~isempty(cw)
            gs(i).ColumnWidth = cw;
        end
    catch
    end
    try
        rh = gs(i).RowHeight;
        if ~isempty(rh)
            gs(i).RowHeight = rh;
        end
    catch
    end
end

end
