function zef_sensors_name_table_selection(hObject,eventdata,handles)
% --- Zeffiro documentation header ---
% zef_sensors_name_table_selection — Zef sensors name table selection.
%
% Purpose:
%   Zef sensors name table selection.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   hObject
%   eventdata
%   handles
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.current_sensor_name (read, write)
%   zef.sensors_selected (read, write)
%
% Calls (project):
%   zef_sensors_name_table_selection
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `zef_sensors_name_table_selection(hObject, eventdata, handles)` with project root and `src` on the path.
% --- End Zeffiro documentation header


sensors_selected = eventdata.Indices(1);

evalin('base', ['zef.current_sensor_name = ' num2str(sensors_selected) ';']);
evalin('base','run(''zef_init_sensor_parameters'')');

sensors_selected = eventdata.Indices(:,1);
sensors_selected = unique(sensors_selected);
sensors_selected = sensors_selected(:)';
evalin('base',['zef.sensors_selected =[' num2str(sensors_selected) '];']);

end
