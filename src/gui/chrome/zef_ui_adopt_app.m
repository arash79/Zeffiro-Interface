function zef_ui_adopt_app(h, name)
%ZEF_UI_ADOPT_APP  Name and theme an App Designer figure that skipped zef_tool_start.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Scripts such as MUSIC_app_start construct an mlapp whose default
%   window title is "MATLAB App". This helper assigns a Zeffiro title,
%   applies the shared theme, and gives the window the same default
%   width as tools launched through zef_tool_start.
%
%   zef_ui_adopt_app(h, name)
%
%   See also zef_ui_ready, zef_ui_apply_size.

if nargin < 1 || isempty(h) || ~isgraphics(h) || ~isvalid(h)
    return
end
if nargin >= 2 && ~isempty(name)
    try
        h.Name = char(string(name));
    catch
    end
end
try
    zef_ui_ready(h);
catch
end
has_layout = false;
try
    has_layout = ~isempty(findall(h, 'Tag', 'zef_ui_root'));
catch
end
if has_layout
    try
        local_stretch_grids(h);
    catch
    end
    return
end
try
    orig = h.Units;
    h.Units = 'pixels';
    ow = h.Position(3);
    oh = h.Position(4);
    n_tbl = numel(findall(h, 'Type', 'uitable'));
    n_col = 0;
    if n_tbl >= 1
        try
            t = findall(h, 'Type', 'uitable');
            n_col = max(n_col, numel(t(1).ColumnName));
            n_col = max(n_col, size(t(1).Data, 2));
        catch
        end
    end
    lname = '';
    try
        lname = lower(char(h.Name));
    catch
    end
    keep_native = false;
    if keep_native
        def_w = max(ow, 360);
        def_h = max(oh, 200);
    else
        def_w = max(520, ow);
        if n_tbl >= 1
            def_w = max(def_w, 640);
        end
        if n_col >= 5
            def_w = max(def_w, 720);
        end
        if n_col >= 6
            def_w = max(def_w, 800);
        end
        def_h = max(oh, 360);
        if n_tbl >= 1
            def_h = max(def_h, 420);
        end
    end
    h.Units = orig;
    zef_ui_apply_size(h, def_w, def_h, max(400, round(0.78 * def_w)), ...
        max(280, round(0.78 * def_h)));
catch
end
try
    local_stretch_grids(h);
catch
end

end

function local_stretch_grids(fig)

gs = findall(fig, 'Type', 'uigridlayout');
for i = 1:numel(gs)
    try
        tg = '';
        try
            tg = char(gs(i).Tag);
        catch
        end
        if any(strcmp(tg, {'zef_bank_cur', 'zef_bank_foot', 'zef_ui_root', ...
                'zef_src_act', 'zef_filter_plot'}))
            continue
        end
        cw = gs(i).ColumnWidth;
        if ~iscell(cw) || numel(cw) < 2
            continue
        end
        has_px = false;
        first_flex = false;
        for k = 1:numel(cw)
            if isnumeric(cw{k})
                has_px = true;
                break
            end
        end
        try
            first_flex = (ischar(cw{1}) || isstring(cw{1})) ...
                && contains(char(string(cw{1})), 'x');
        catch
        end
        if has_px || first_flex
            continue
        end
        cw{end} = '1x';
        gs(i).ColumnWidth = cw;
    catch
    end
end

end
