function zef_ui_bind_min_size(h, min_w, min_h)
%ZEF_UI_BIND_MIN_SIZE  Clamp a figure on resize without dropping layout Fcn.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Stores [min_w min_h] on the figure and wraps SizeChangedFcn so a
%   shrink cannot go below the floor.
%
%   AutoResizeChildren is turned off on every figure, including those with
%   a zef_ui_root grid. MATLAB refuses to run SizeChangedFcn while it is on
%   ("'SizeChangedFcn' callback will not execute while 'AutoResizeChildren'
%   is set to 'on'"), and a uigridlayout does not follow AutoResizeChildren
%   in any case: with it off the grid keeps whatever Position it was given,
%   so zef_ui_adapt_grid has to stretch zef_ui_root to the live figure size
%   explicitly. SizeChangedFcn is the only resize entry. Extra SizeChanged
%   and Position PostSet listeners used to run this callback two more times
%   per pixel (and on origin-only moves), which froze the Figure tool.
%
%   zef_ui_bind_min_size(h, min_w, min_h)
%
%   See also zef_ui_apply_size, zef_ui_adapt_grid.

if nargin < 1 || isempty(h) || ~isgraphics(h) || ~isvalid(h)
    return
end
if nargin < 2 || isempty(min_w)
    min_w = 360;
end
if nargin < 3 || isempty(min_h)
    min_h = 280;
end

try
    if isappdata(h, 'ZefMinSize')
        prev = getappdata(h, 'ZefMinSize');
        if numel(prev) >= 2
            min_w = max(double(min_w), double(prev(1)));
            min_h = max(double(min_h), double(prev(2)));
        end
    end
catch
end

try
    setappdata(h, 'ZefMinSize', [double(min_w), double(min_h)]);
catch
    return
end

try
    if isprop(h, 'MinSize')
        h.MinSize = [double(min_w), double(min_h)];
    end
catch
end

% Must precede the SizeChangedFcn assignment below: MATLAB warns and
% disables the callback if AutoResizeChildren is still on.
try
    h.AutoResizeChildren = 'off';
catch
end

wrapper = [];
try
    if isappdata(h, 'ZefMinSizeFcn')
        wrapper = getappdata(h, 'ZefMinSizeFcn');
    end
catch
end
if isempty(wrapper)
    wrapper = @(src, evt) zef_ui_min_size_callback(src, evt);
    setappdata(h, 'ZefMinSizeFcn', wrapper);
end

current = [];
try
    current = h.SizeChangedFcn;
catch
end
if ~isempty(current) && ~isequal(current, wrapper)
    try
        setappdata(h, 'ZefSizeChangedInner', current);
    catch
    end
end
try
    h.SizeChangedFcn = wrapper;
catch
end

local_drop_extra_listeners(h);

try
    zef_ui_adapt_grid(h);
catch
end

end

function zef_ui_min_size_callback(src, evt)

if ~isgraphics(src) || ~isvalid(src)
    return
end
if isappdata(src, 'ZefResizeBusy') && isequal(getappdata(src, 'ZefResizeBusy'), true)
    return
end
setappdata(src, 'ZefResizeBusy', true);

grew = false;
try
    mins = [360, 280];
    if isappdata(src, 'ZefMinSize')
        mins = getappdata(src, 'ZefMinSize');
    end
    maxs = [];
    if isappdata(src, 'ZefMaxSize')
        maxs = getappdata(src, 'ZefMaxSize');
    end
    orig = src.Units;
    src.Units = 'pixels';
    p = src.Position;
    if p(3) < mins(1)
        p(3) = mins(1);
        grew = true;
    end
    if p(4) < mins(2)
        p(4) = mins(2);
        grew = true;
    end
    if numel(maxs) >= 2
        if p(3) > maxs(1)
            p(3) = maxs(1);
            grew = true;
        end
        if p(4) > maxs(2)
            p(4) = maxs(2);
            grew = true;
        end
    end
    if grew
        src.Position = p;
    end
    token = [p(3), p(4)];
    prev_token = [];
    if isappdata(src, 'ZefSizeToken')
        prev_token = getappdata(src, 'ZefSizeToken');
    end
    setappdata(src, 'ZefSizeToken', token);
    src.Units = orig;
    if ~grew && isequal(prev_token, token)
        setappdata(src, 'ZefResizeBusy', false);
        return
    end
catch
end

try
    % Compact GUIDE forms store ZefGuideForm and have no zef_ui_root.
    % zef_ui_adapt_grid dispatches: GuideForm → zef_layout_guide_form,
    % uigrid → stretch root, else ZefPixelResize.
    zef_ui_adapt_grid(src);
catch
end

try
    prev = [];
    if isappdata(src, 'ZefSizeChangedInner')
        prev = getappdata(src, 'ZefSizeChangedInner');
    end
    if isa(prev, 'function_handle')
        prev(src, evt);
    elseif (ischar(prev) || isstring(prev)) && strlength(prev) > 0
        evalin('base', char(prev));
    end
catch
end

setappdata(src, 'ZefResizeBusy', false);

end

function local_drop_extra_listeners(h)

local_delete_appdata_listener(h, 'ZefMinSizeListener');
local_delete_appdata_listener(h, 'ZefMinSizePosListener');

end

function local_delete_appdata_listener(h, key)

try
    if ~isappdata(h, key)
        return
    end
    lh = getappdata(h, key);
    if ~isempty(lh) && isvalid(lh)
        delete(lh);
    end
    rmappdata(h, key);
catch
end

end
