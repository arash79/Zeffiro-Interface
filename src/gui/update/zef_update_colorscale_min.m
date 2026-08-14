function slider_value_new = zef_update_colorscale_min(varargin)
%ZEF_UPDATE_COLORSCALE_MIN  Figure-tool **Color min:** slider.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Finds the slider Tag='colorscale_min_slider' on the Figure tool
%   (or on varargin{1} if a popped-out figure was passed) and multiplies
%   axes1 CLim(1) by 10^(slider Value). Slider range is [-1, 1]; 0 is
%   identity. Unlike **Color max:**, this uses the absolute slider Value,
%   not a delta against UserData (UserData is still stored for callers).
%
%   Then calls zef_update_contour so contour levels follow the new CLim.
%   The Figure-tool Callback writes the returned value to
%   zef.colorscale_min_slider when gca is parented to h_zeffiro.
%
%   slider_value_new = zef_update_colorscale_min
%   slider_value_new = zef_update_colorscale_min(h_figure)
%
%   See also zef_update_colorscale_max, zef_update_colorscale, zef_update_contour.
if isequal(evalin('caller','exist(''zef'')'),1)
    zef = evalin('caller','zef');
else
    zef = evalin('base','zef');
end

if not(isempty(varargin))
    h_figure = varargin{1};
else
    h_figure = eval('zef.h_zeffiro');
end

h = findobj(get(h_figure,'Children'),'Tag','axes1');
h_object = findobj(get(h_figure,'Children'),'Tag','colorscale_min_slider');
if isempty(h_object)
    h_figure = eval('zef.h_zeffiro');
    h_object = findobj(get(h_figure,'Children'),'Tag','colorscale_min_slider');
end

slider_value_new = h_object.Value;

if isempty(h_object.UserData)
    slider_value_old = 0;
else
    slider_value_old = h_object.UserData;
end

h_object.UserData = slider_value_new;

clim_vec = h.CLim;
% Decade shift of the lower CLim bound: CLim(1) *= 10^Value (absolute, not delta).
clim_vec(1) = clim_vec(1)*10^(slider_value_new);
h.CLim = clim_vec;

zef_update_contour(zef);

end
