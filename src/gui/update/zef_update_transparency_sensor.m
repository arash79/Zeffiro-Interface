function slider_value_new = zef_update_transparency_sensor(varargin)
%ZEF_UPDATE_TRANSPARENCY_SENSOR  Figure-tool **Transp. sens.:** slider.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Finds the slider Tag='transparency_sensor_slider' on the Figure
%   tool (or on varargin{1} if a popped-out figure was passed), then sets
%   FaceAlpha on every patch Tag='sensor' in axes1 (electrodes / coils
%   from zef_plot_volume / zef_plot_meshes).
%
%   Alpha is 1.05^(-100*slider). Slider 0 → opaque; larger values fade
%   sensors. The Figure-tool Callback writes the returned value to
%   zef.update_transparency_sensor when gca is parented to h_zeffiro.
%
%   Sibling sliders: zef_update_transparency_reconstruction / _surface /
%   _cones / _additional. Wired as Callback strings from zef_figure_tool.
%
%   slider_value_new = zef_update_transparency_sensor
%   slider_value_new = zef_update_transparency_sensor(h_figure)
%
%   See also zef_update_transparency_reconstruction, zef_figure_tool.
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
h_object = zef_ui_control(h_figure, 'transparency_sensor_slider');

slider_value_new = h_object.Value;

h = findobj(h,'Tag','sensor');

% Same kappa as reconstruction: FaceAlpha = min(1, 1.05^(-100*slider)).
kappa = 1.05.^(-100*(slider_value_new));

for i = 1 : length(h)

    h(i).FaceAlpha = min(1,kappa);

end

end
