function zef_ui_bind_min_size(h, min_w, min_h)
%ZEF_UI_BIND_MIN_SIZE  Clamp a figure on resize without dropping layout Fcn.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Stores [min_w min_h] on the figure and wraps SizeChangedFcn so a
%   shrink cannot go below the floor. uigridlayout still follows the
%   figure size on its own; AutoResizeChildren is turned off after a
%   zef_ui_root grid is installed so MATLAB will actually run the clamp.
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
    setappdata(h, 'ZefMinSize', [double(min_w), double(min_h)]);
catch
    return
end

has_grid = false;
try
    has_grid = ~isempty(findall(h, 'Tag', 'zef_ui_root'));
catch
end
if has_grid
    try
        h.AutoResizeChildren = 'off';
    catch
    end
else
    ar = 'off';
    try
        ar = char(h.AutoResizeChildren);
    catch
    end
    if strcmpi(ar, 'on')
        return
    end
end

current = [];
try
    current = h.SizeChangedFcn;
catch
end

our = [];
if isappdata(h, 'ZefMinSizeFcn')
    our = getappdata(h, 'ZefMinSizeFcn');
end
if ~isempty(our) && isequal(current, our)
    try
        zef_ui_adapt_grid(h);
    catch
    end
    return
end

try
    setappdata(h, 'ZefSizeChangedInner', current);
    wrapper = @(src, evt) zef_ui_min_size_callback(src, evt);
    h.SizeChangedFcn = wrapper;
    setappdata(h, 'ZefMinSizeFcn', wrapper);
catch
end

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

try
    mins = [360, 280];
    if isappdata(src, 'ZefMinSize')
        mins = getappdata(src, 'ZefMinSize');
    end
    orig = src.Units;
    src.Units = 'pixels';
    p = src.Position;
    grew = false;
    if p(3) < mins(1)
        p(3) = mins(1);
        grew = true;
    end
    if p(4) < mins(2)
        p(4) = mins(2);
        grew = true;
    end
    if grew
        src.Position = p;
    end
    src.Units = orig;
catch
end

try
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
