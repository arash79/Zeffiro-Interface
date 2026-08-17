function slider_value_new = zef_update_colorscale_max(varargin)
%ZEF_UPDATE_COLORSCALE_MAX  Figure-tool **Color max:** slider.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Finds the slider Tag='colorscale_max_slider' on the Figure tool
%   (or on varargin{1} if a popped-out figure was passed). Multiplies
%   axes1 CLim(2) by 10^(new-old), where old is the previous Value stored
%   in the slider UserData. Slider range is [-1, 1]; 0 is identity.
%   Decade scaling is incremental so dragging does not compound from the
%   original CLim on every callback.
%
%   Then calls zef_update_contour so contour levels follow the new CLim.
%   The Figure-tool Callback writes the returned value to
%   zef.colorscale_max_slider when gca is parented to h_zeffiro.
%
%   slider_value_new = zef_update_colorscale_max
%   slider_value_new = zef_update_colorscale_max(h_figure)
%
%   See also zef_update_colorscale_min, zef_update_colorscale, zef_update_contour.
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

h = zef_ui_axes(h_figure);
h_object = zef_ui_control(h_figure, 'colorscale_max_slider');

slider_value_new = h_object.Value;

if isempty(h_object.UserData)
    slider_value_old = 0;
else
    slider_value_old = h_object.UserData;
end

h_object.UserData = slider_value_new;

clim_vec = h.CLim;
% Incremental decade shift: CLim(2) *= 10^(new-old) so each drag step is relative.
if length(slider_value_new) == 1
    clim_vec(2) = clim_vec(2)*10^(slider_value_new - slider_value_old);
else
    clim_vec(2) = clim_vec(2)*10^(slider_value_new - slider_value_old);
end

h.CLim = clim_vec;
zef_update_contour(zef);

end
