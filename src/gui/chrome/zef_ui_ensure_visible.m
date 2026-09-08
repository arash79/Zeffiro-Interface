function zef_ui_ensure_visible(fig, pad)
%ZEF_UI_ENSURE_VISIBLE  Grow a figure when controls clip the window edges.
%
%   zef_ui_ensure_visible(fig)
%   zef_ui_ensure_visible(fig, pad)
%
%   Scans visible controls and expands Position(3:4) when content extends
%   past the client area. Updates zef_ui_root when present.
%
%   See also zef_ui_apply_size, zef_layout_form_dialog.

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
if nargin < 2 || isempty(pad)
    pad = 12;
end

try
    drawnow;
catch
end

try
    orig = fig.Units;
    fig.Units = 'pixels';
    W = fig.Position(3);
    H = fig.Position(4);
    min_x = 0;
    min_y = 0;
    max_x = W;
    max_y = H;
    types = {'uilabel', 'uieditfield', 'uinumericeditfield', 'uidropdown', ...
        'uicheckbox', 'uibutton', 'uispinner', 'uitextarea', 'uitable', ...
        'uipanel', 'uiimage', 'uilistbox', 'uitree'};
    objs = gobjects(0);
    for ti = 1:numel(types)
        objs = [objs; findall(fig, 'Type', types{ti})]; %#ok<AGROW>
    end
    try
        objs = [objs; findall(fig, 'Style', 'pushbutton')];
        objs = [objs; findall(fig, 'Style', 'text')];
        objs = [objs; findall(fig, 'Style', 'edit')];
        objs = [objs; findall(fig, 'Style', 'popupmenu')];
        objs = [objs; findall(fig, 'Style', 'checkbox')];
    catch
    end
    for i = 1:numel(objs)
        if ~isgraphics(objs(i)) || ~isvalid(objs(i))
            continue
        end
        try
            if ~strcmpi(char(objs(i).Visible), 'on')
                continue
            end
        catch
        end
        try
            if strcmp(objs(i).Type, 'uilabel')
                txt = strtrim(char(string(objs(i).Text)));
                if isempty(txt)
                    continue
                end
            end
        catch
        end
        if local_in_scrollable(objs(i), fig)
            continue
        end
        gp = [0 0 0 0];
        try
            gp = getpixelposition(objs(i), true);
        catch
            continue
        end
        if numel(gp) < 4 || gp(3) < 2 || gp(4) < 2
            continue
        end
        min_x = min(min_x, gp(1));
        min_y = min(min_y, gp(2));
        max_x = max(max_x, gp(1) + gp(3));
        max_y = max(max_y, gp(2) + gp(4));
    end
    extra_w = 0;
    extra_h = 0;
    if min_x < pad
        extra_w = extra_w + (pad - min_x);
    end
    if max_x > W - pad
        extra_w = extra_w + (max_x - W + pad);
    end
    if min_y < pad
        extra_h = extra_h + (pad - min_y);
    end
    if max_y > H - pad
        extra_h = extra_h + (max_y - H + pad);
    end
    if extra_w > 8 || extra_h > 8
        scr = get(groot, 'ScreenSize');
        nw = min(W + extra_w, min(round(0.96 * scr(3)), scr(3) - 16));
        nh = min(H + extra_h, min(round(0.96 * scr(4)), scr(4) - 48));
        fig.Position(3) = nw;
        fig.Position(4) = nh;
        root = findall(fig, 'Tag', 'zef_ui_root');
        if ~isempty(root)
            try
                root(1).Position = [1 1 nw nh];
            catch
            end
        end
        try
            if isappdata(fig, 'ZefMinSize')
                ms = getappdata(fig, 'ZefMinSize');
                zef_ui_bind_min_size(fig, max(ms(1), min(round(0.88 * nw), nw)), ...
                    max(ms(2), min(round(0.85 * nh), nh)));
            end
        catch
        end
    end
    fig.Units = orig;
catch
end

end

function tf = local_in_scrollable(obj, fig)

tf = false;
if nargin < 1 || isempty(obj) || ~isgraphics(obj)
    return
end
p = obj;
guard = 0;
while isgraphics(p) && isvalid(p) && guard < 16
    try
        if nargin >= 2 && isgraphics(fig) && isequal(p, fig)
            return
        end
    catch
    end
    try
        if isprop(p, 'Scrollable') && strcmpi(char(string(p.Scrollable)), 'on')
            tf = true;
            return
        end
    catch
    end
    try
        p = p.Parent;
    catch
        return
    end
    guard = guard + 1;
end

end
