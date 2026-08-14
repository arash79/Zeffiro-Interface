function slider_value_new = zef_update_transparency_reconstruction(varargin)
%ZEF_UPDATE_TRANSPARENCY_RECONSTRUCTION  Figure-tool **Transp. rec.:** slider.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Finds the slider Tag='transparency_reconstruction_slider' on the Figure
%   tool (or on varargin{1} if a popped-out figure was passed), then sets
%   FaceAlpha on every patch Tag='reconstruction' in axes1.
%
%   Alpha is 1.05^(-100*slider). Slider 0 → opaque; larger values fade
%   the reconstruction so surfaces behind it show through. Non-numeric
%   FaceAlpha (e.g. 'interp') is replaced by min(1,kappa); numeric alpha
%   is overwritten the same way in the loop body.
%
%   Sibling sliders: zef_update_transparency_surface / _sensor / _cones /
%   _additional. Wired as Callback strings from zef_figure_tool.
%
%   slider_value_new = zef_update_transparency_reconstruction
%   slider_value_new = zef_update_transparency_reconstruction(h_figure)
%
%   See also zef_update_transparency_surface, zef_figure_tool.

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
h_object = findobj(get(h_figure,'Children'),'Tag','transparency_reconstruction_slider');
if isempty(h_object)
    h_figure = eval('zef.h_zeffiro');
    h_object = findobj(get(h_figure,'Children'),'Tag','transparency_reconstruction_slider');
end

slider_value_new = h_object.Value;

h = findobj(h,'Tag','reconstruction');

kappa = 1.05.^(-100*(slider_value_new));

for i = 1 : length(h)

    if not(isnumeric(h(i).FaceAlpha))
        h(i).FaceAlpha = min(1,kappa);
    else
        h(i).FaceAlpha = min(1,kappa);
    end

end

end
