function zef_set_lights(lights_vec,varargin)
%ZEF_SET_LIGHTS  Push zef.update_lights onto an axes (no popup read).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Inverse of zef_update_lights: deletes existing Light
%   objects on varargin{1} (default zef.h_axes1) and recreates them from
%   the code vector (1 = ±z, 3 = ±x, 4 = ±y, 5 = ±z again, 6 =
%   camlight headlight). Called from zef_set_sliders_plot / _print after
%   a redraw so the new patches get the stored lighting. Code 2 (lights
%   off) is a no-op here because lights were already deleted.
%
%   See also zef_update_lights, zef_set_sliders_plot.
if isequal(evalin('caller','exist(''zef'')'),1)
    zef = evalin('caller','zef');
else
    zef = evalin('base','zef');
end

if not(isempty(varargin))
    h_1 = varargin{1};
else
    h_1 = eval('zef.h_axes1');
end

delete(findobj(h_1.Children,'Type','Light'));

for i = 1 : length(lights_vec)

    aux_val = lights_vec(i);

    if aux_val == 1

        light(h_1,'Position',[0 0 1],'Style','infinite');
        light(h_1,'Position',[0 0 -1],'Style','infinite');

    elseif aux_val == 3

        light(h_1,'Position',[1 0 0],'Style','infinite');
        light(h_1,'Position',[-1 0 0 ],'Style','infinite');

    elseif aux_val == 4

        light(h_1,'Position',[0 1 0],'Style','infinite');
        light(h_1,'Position',[0 -1 0 ],'Style','infinite');

    elseif aux_val == 5

        light(h_1,'Position',[0 0 1],'Style','infinite');
        light(h_1,'Position',[0 0 -1 ],'Style','infinite');

    elseif aux_val == 6

        camlight(h_1,'headlight')

    end

end
