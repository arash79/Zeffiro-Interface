function  diffusion_val = zef_update_diffusion(varargin)
%ZEF_UPDATE_DIFFUSION  Figure-tool **Diffusion:** slider.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Finds the slider Tag='update_diffusion_slider' on the Figure tool
%   (or on varargin{1}) and sets DiffuseStrength on every axes1 child
%   that has that property. Range 0–1. This is Lambert diffuse lighting,
%   not conductivity / DTI diffusion.
%
%   The Figure-tool Callback writes the returned value to
%   zef.update_diffusion when gca is parented to h_zeffiro.
%
%   diffusion_val = zef_update_diffusion
%   diffusion_val = zef_update_diffusion(h_figure)
%
%   See also zef_update_ambience, zef_update_specular, zef_figure_tool.
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
h_object = zef_ui_control(h_figure, 'update_diffusion_slider');

diffusion_val = h_object.Value;
h = h.Children;

for i = 1 : length(h)

    if not(isempty(find(ismember(properties(h(i)),'DiffuseStrength'))))
        h(i).DiffuseStrength = diffusion_val;
    end

end
