% --- Zeffiro documentation header ---
% zef — Zef.
%
% Purpose:
%   Zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.current_sensors (read, write)
%   zef.current_tag (read, write)
%
% Calls (project):
%   zef_create_sensors
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.sensor_tags = cell(0);
zef.current_sensors = 's';
zef.current_tag = 's';
zef = zef_create_sensors(zef,'s');
