function zef = zef_delete_all_compartments(zef)
% --- Zeffiro documentation header ---
% zef_delete_all_compartments — Zef delete all compartments.
%
% Purpose:
%   Zef delete all compartments.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.compartment_tags (read)
%   zef.compartments_selected (read, write)
%   zef.h_compartment_table (read)
%   zef.h_sensors_table (read)
%   zef.sensor_sets_selected (read, write)
%   zef.sensor_tags (read)
%
% Calls (project):
%   zef_delete_all_compartments
%   zef_delete_compartment
%   zef_delete_sensor_sets
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[zef] = zef_delete_all_compartments(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

if not(isempty(zef.h_compartment_table.Data))
    for zef_i = 1 : length(zef.h_compartment_table.Data(:,2))
        zef.h_compartment_table.Data{zef_i,2} = 0;
    end
    for zef_i = 1 : length(zef.h_sensors_table.Data(:,4))
        zef.h_sensors_table.Data{zef_i,4} = 0;
    end
    clear zef_i;
    zef.compartments_selected = [1 : length(zef.compartment_tags)];
    zef = zef_delete_compartment(zef);
    zef.compartments_selected = [];
    zef.sensor_sets_selected = [1 : length(zef.sensor_tags)];
    zef = zef_delete_sensor_sets(zef);
    zef.sensor_sets_selected = [];
end

if nargout == 0
    assignin('base','zef',zef);
end


end
