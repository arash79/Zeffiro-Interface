function zef = zef_delete_sensor_sets(zef)
% --- Zeffiro documentation header ---
% zef_delete_sensor_sets — Zef delete sensor sets.
%
% Purpose:
%   Zef delete sensor sets.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.h_sensors_table (read)
%   zef.sensor_sets_selected (read)
%
% Calls (project):
%   zef_delete_sensor_sets
%   zef_update
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[zef] = zef_delete_sensor_sets(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

table_data = eval('zef.h_sensors_table.Data');
sensor_sets_selected = eval('zef.sensor_sets_selected');

for i = 1 : length(sensor_sets_selected)
    if not(table_data{sensor_sets_selected(i),4})
        eval(['zef.h_sensors_table.Data{' num2str(table_data{sensor_sets_selected(i),1}) '} = NaN;'])
    end
end

zef = zef_update(zef);

if nargout == 0
    assignin('base','zef',zef);
end

end
