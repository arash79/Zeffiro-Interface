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
%   The clamp always runs inside the resize event. The layout pass runs
%   synchronously for grid and simple windows; manual pixel layouts
%   (ZefPixelResize / ZefGuideForm) defer to a coalescing one-shot timer,
%   because their repaint work (cards, axes images, uistack) inside a
%   live resize event deadlocks, while the same work from the main
%   thread is ~0.1 s.
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
%ZEF_UI_MIN_SIZE_CALLBACK  Clamp synchronously; run layout where it is safe.
%
%   The min/max clamp always runs here, inside the resize event. The
%   layout pass (adapt_grid + the chained inner SizeChangedFcn) runs
%   synchronously for grid and simple windows. Manual pixel layouts
%   (ZefPixelResize / ZefGuideForm markers: strip tool, FSS ROI, GUIDE
%   forms) repaint card axes and uistack; that work deadlocks the event
%   dispatch when it runs inside a live resize event, while the same
%   work from the main thread completes in ~0.1 s. Those windows get a
%   debounced one-shot timer that re-clamps and lays out only after the
%   resize churn settles. A pending timer keeps ZefResizeBusy true, and
%   every further size event restarts it, so the last resize wins and
%   the layout never runs mid-drag.

if ~isgraphics(src) || ~isvalid(src)
    return
end
if isappdata(src, 'ZefResizeBusy') && isequal(getappdata(src, 'ZefResizeBusy'), true)
    % A deferred pass is pending. Restart it so the layout runs only
    % after the resize churn settles: repainting card axes while the
    % renderer is still applying size changes deadlocks the sync points
    % (drawnow / exportapp), so never lay out mid-drag.
    if isappdata(src, 'ZefPixelResize') || isappdata(src, 'ZefGuideForm')
        local_schedule_layout(src, evt);
    end
    return
end
setappdata(src, 'ZefResizeBusy', true);

grew = local_clamp(src);
token_changed = local_stamp_token(src);
if ~grew && ~token_changed
    setappdata(src, 'ZefResizeBusy', false);
    return
end

if isappdata(src, 'ZefPixelResize') || isappdata(src, 'ZefGuideForm')
    % Manual pixel layouts (strip tool, FSS ROI, GUIDE forms/windows)
    % repaint card axes and uistack inside SizeChangedFcn. That work
    % inside a live resize event deadlocks; from the main thread the
    % identical pass is ~0.1 s. Defer it to a debounced one-shot timer.
    local_schedule_layout(src, evt);
else
    local_run_layout(src, evt);
end

end

function grew = local_clamp(src)

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
    % Tolerance against fractional retina/DPI sizes: macOS windows can
    % report 699.6 px for a 700 px client area. Clamping that to the
    % integer floor re-sets Position inside the live resize event, which
    % the window system cannot apply, so every event re-queues another
    % clamp and drawnow never drains. Only correct shortfalls > 1 px.
    tol = 1;
    if p(3) < mins(1) - tol
        p(3) = mins(1);
        grew = true;
    end
    if p(4) < mins(2) - tol
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
        try
            if isprop(src, 'InnerPosition')
                ip = double(src.InnerPosition);
                if numel(ip) >= 4
                    % Retina/DPI scaling makes InnerPosition fractional
                    % (e.g. 699.6 for a 700 px client area). Clamping on a
                    % sub-pixel shortfall re-sets InnerPosition, which
                    % queues another resize event and livelocks drawnow at
                    % the exact floor. Only correct real shortfalls.
                    tol = 1;
                    inner_grew = false;
                    if ip(3) < mins(1) - tol
                        ip(3) = mins(1);
                        inner_grew = true;
                    end
                    if ip(4) < mins(2) - tol
                        ip(4) = mins(2);
                        inner_grew = true;
                    end
                    if inner_grew
                        src.InnerPosition = ip;
                    end
                end
            end
        catch
        end
    end
    src.Units = orig;
catch
end

end

function changed = local_stamp_token(src)

changed = false;
try
    p = src.Position;
    token = [p(3), p(4)];
    prev_token = [];
    if isappdata(src, 'ZefSizeToken')
        prev_token = getappdata(src, 'ZefSizeToken');
    end
    setappdata(src, 'ZefSizeToken', token);
    changed = ~isequal(prev_token, token);
catch
end

end

function local_run_layout(src, evt)

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

function local_schedule_layout(src, evt)

% Debounce: one pending one-shot timer per figure. Every size event
% restarts it, so the layout (and the card repaint) runs only after the
% resize churn has settled — the renderer-sync deadlock only strikes
% while size changes are still being applied.
try
    if isappdata(src, 'ZefResizeTimer')
        cand = getappdata(src, 'ZefResizeTimer');
        if istimer(cand)
            stop(cand);
            delete(cand);
        end
        rmappdata(src, 'ZefResizeTimer');
    end
catch
end
try
    t = timer('Name', 'zef_resize_layout', ...
        'StartDelay', 0.25, 'ExecutionMode', 'singleShot', ...
        'BusyMode', 'drop', 'ObjectVisibility', 'off', ...
        'TimerFcn', @local_timer_layout);
    t.UserData = {src, evt};
    setappdata(src, 'ZefResizeTimer', t);
    start(t);
catch
    % Timer creation failed (e.g. MATLAB shutting down): fall back to a
    % direct layout pass; a stuck resize is worse than a risky one.
    local_run_layout(src, evt);
end

end

function local_timer_layout(t, ~)
%   MATLAB passes the timer object as the first argument; the figure and
%   event are carried in its UserData.

src = [];
evt = [];
try
    ud = t.UserData;
    if iscell(ud)
        if numel(ud) >= 1
            src = ud{1};
        end
        if numel(ud) >= 2
            evt = ud{2};
        end
    end
catch
end
try
    if isappdata(src, 'ZefResizeTimer')
        cand = getappdata(src, 'ZefResizeTimer');
        if cand == t
            rmappdata(src, 'ZefResizeTimer');
        end
    end
    stop(t);
    delete(t);
catch
end
if ~isgraphics(src) || ~isvalid(src)
    return
end
% A fast drag can dip below the floor while the timer was pending.
try
    local_clamp(src);
catch
end
local_run_layout(src, evt);

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
