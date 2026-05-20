% --- Zeffiro documentation header ---
% zef = zef_create_sensors(zef,['s' num2str(length(zef — Zef = zef create sensors(zef,['s' num2str(length(zef.
%
% Purpose:
%   Zef = zef create sensors(zef,['s' num2str(length(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.aux_field_1 (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef = zef_create_sensors(zef,['s' num2str(length(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef = zef_create_sensors(zef,['s' num2str(length(zef.sensor_tags) + 1)]);
zef.aux_field_1 = cell(0);
zef_build_sensors_table;
