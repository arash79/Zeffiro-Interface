function zef_slidding_callback(varargin)
%ZEF_SLIDDING_CALLBACK  Figure-tool **Time:** slider (legacy spelling).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wired as Callback of zef.h_slider in zef_figure_tool. If
%   zef.store_cdata is true, plays one stored frame via
%   zef_play_cdata(1, slider Value). Otherwise maps the slider (0–1)
%   onto the frame range and writes both zef.frame_start and
%   zef.frame_stop to that index, then redraws when the frame actually
%   changed: visualization_type 2 → zef_visualize_volume, 3 →
%   zef_visualize_surfaces.
%
%   See also zef_figure_tool, zef_play_cdata.

zef = evalin('base', 'zef');

src = [];
if nargin >= 1 && ~isempty(varargin{1}) && isgraphics(varargin{1})
    src = varargin{1};
end
if isempty(src)
    try
        src = gcbo;
    catch
        src = [];
    end
end
if isempty(src) && isfield(zef, 'h_slider') && ~isempty(zef.h_slider)
    cand = zef.h_slider;
    src = cand(1);
end
if isempty(src) || ~isgraphics(src) || ~isvalid(src)
    return
end

val = [];
try
    val = double(src.Value);
    val = val(1);
catch
    return
end
if isempty(val) || ~isfinite(val)
    return
end

store = false;
try
    store = logical(zef.store_cdata);
    store = store(1);
catch
end
if store
    zef_play_cdata(1, val);
    return
end

fs = 1;
fe = 1;
st = 1;
try
    if ~isempty(zef.frame_start)
        fs = double(zef.frame_start(1));
    end
    if ~isempty(zef.frame_stop)
        fe = double(zef.frame_stop(1));
    end
    if ~isempty(zef.frame_step)
        st = double(zef.frame_step(1));
    end
catch
end
if ~isfinite(fs) || ~isfinite(fe) || ~isfinite(st) || st == 0
    return
end
l_r = (fe - fs + st) / st;
new_frame = max(1, ceil(l_r * val));
if isequal(new_frame, fs) && isequal(new_frame, fe)
    return
end
zef.frame_start = new_frame;
zef.frame_stop = new_frame;
assignin('base', 'zef', zef);

vis = 0;
try
    vis = double(zef.visualization_type(1));
catch
end
if vis == 2
    zef_visualize_volume;
elseif vis == 3
    zef_visualize_surfaces;
end

end
