function slider_value_new = zef_update_transparency_additional(varargin)
%ZEF_UPDATE_TRANSPARENCY_ADDITIONAL  Figure-tool **Transp. add.:** slider.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Finds the slider Tag='transparency_additional_slider' on the Figure
%   tool (or on varargin{1} if a popped-out figure was passed), then sets
%   FaceAlpha on every axes1 child whose Tag matches regexp 'additional*'
%   (plugin / extra overlays; first-party plotters tag reconstruction,
%   surface, sensor, and cones instead).
%
%   Alpha is 1.05^(-100*slider). Slider 0 → opaque; larger values fade
%   those patches. The Figure-tool Callback writes the returned value to
%   zef.update_transparency_additional when gca is parented to h_zeffiro.
%
%   Sibling sliders: zef_update_transparency_reconstruction / _surface /
%   _sensor / _cones. Wired as Callback strings from zef_figure_tool.
%
%   slider_value_new = zef_update_transparency_additional
%   slider_value_new = zef_update_transparency_additional(h_figure)
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

h = findobj(get(h_figure,'Children'),'Tag','axes1');
h_object = findobj(get(h_figure,'Children'),'Tag','transparency_additional_slider');
if isempty(h_object)
    h_figure = eval('zef.h_zeffiro');
    h_object = findobj(get(h_figure,'Children'),'Tag','transparency_additional_slider');
end

slider_value_new = h_object.Value;

h = findobj(h,'-regexp','Tag','additional*');

% Same kappa as reconstruction: FaceAlpha = min(1, 1.05^(-100*slider)).
kappa = 1.05.^(-100*(slider_value_new));

for i = 1 : length(h)

    h(i).FaceAlpha = min(1,kappa);

end
end
