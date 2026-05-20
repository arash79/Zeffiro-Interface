% --- Zeffiro documentation header ---
% function zef_set_sensor_color — Function zef set sensor color.
%
% Purpose:
%   Function zef set sensor color.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.current_sensors (read)
%   zef.h_sensor_visible_color (read)
%
% Calls (project):
%   zef_set_sensor_color
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function zef_set_sensor_color` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function zef_set_sensor_color


color_vec = uisetcolor;
item_ind_1 = evalin('base','zef.h_sensor_visible_color.Value');
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
