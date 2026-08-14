function zef_set_sensor_color
%ZEF_SET_SENSOR_COLOR  Figure-tool **Sensors:** list ButtonDownFcn.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. uisetcolor; maps each h_sensor_visible_color.Value through
%   current_sensors _visible_list (same order zef_update_fig_details used)
%   and writes that row of zef.<sensors>_color_table in base. Wired in
%   zef_figure_tool with zef_update after. Does not itself redraw axes1.
%
%   See also zef_update_fig_details, zef_set_compartment_color.

color_vec = uisetcolor;
item_ind_1 = zef_colored_list('value', evalin('base','zef.h_sensor_visible_color'));
if isempty(item_ind_1)
    return
end
current_sensors = evalin('base','zef.current_sensors');
visible_list = evalin('base',['zef.' current_sensors '_visible_list']);

for zef_k = 1 : length(item_ind_1)
    item_ind_2 = item_ind_1(zef_k);
    zef_j = 0;
    for zef_i = 1 : length(visible_list)
        if visible_list(zef_i)
            zef_j = zef_j + 1;
            if zef_j == item_ind_2
                item_ind_2 = zef_i;
                break;
            end
        end
    end

    evalin('base',['zef.' current_sensors '_color_table(' num2str(item_ind_2) ',:) = [' num2str(color_vec) '];']);

end
end
