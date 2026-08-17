function kappa = zef_update_zoom(varargin)
%ZEF_UPDATE_ZOOM  Figure-tool **Distance:** slider.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Finds the slider Tag='update_zoom_slider' on the Figure tool
%   (or on varargin{1} if a popped-out figure was passed) and assigns
%   axes1 CameraViewAngle to the slider Value. Range is 0.1–100 degrees
%   (larger angle = more of the scene, i.e. zoomed out). Default lives in
%   zef.update_zoom / zef.cam_va.
%
%   The Figure-tool Callback writes the returned value to zef.update_zoom
%   when gca is parented to h_zeffiro.
%
%   kappa = zef_update_zoom
%   kappa = zef_update_zoom(h_figure)
%
%   See also zef_figure_tool, zef_set_sliders_plot.
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
h_object = zef_ui_control(h_figure, 'update_zoom_slider');

kappa = h_object.Value;
h.CameraViewAngle = kappa;

end
