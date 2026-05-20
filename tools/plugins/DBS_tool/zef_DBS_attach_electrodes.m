function zef = zef_DBS_attach_electrodes(zef)
% --- Zeffiro documentation header ---
% zef_DBS_attach_electrodes — Zef DBS attach electrodes.
%
% Purpose:
%   Zef DBS attach electrodes.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.current_sensors (read)
%   zef.sensors_visual_size (read, write)
%   zef.strip_struct (read)
%
% Calls (project):
%   zef_DBS_attach_electrodes
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_DBS_attach_electrodes(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


eval(['zef.' zef.current_sensors '_points=zef.strip_struct.electrode_data;']);
eval(['zef.' zef.current_sensors '_electrode_outer_radius=zef.strip_struct.electrode_data(:,4);']);
eval(['zef.' zef.current_sensors '_electrode_inner_radius=zef.strip_struct.electrode_data(:,5);']);
eval(['zef.' zef.current_sensors '_electrode_impedance=zef.strip_struct.electrode_data(:,6);']);
zef.sensors_visual_size = zef.strip_struct.electrode_radius/2;
end
