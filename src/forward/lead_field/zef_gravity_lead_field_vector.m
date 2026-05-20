% --- Zeffiro documentation header ---
% warning('off'); — Warning('off');.
%
% Purpose:
%   Warning('off');.
%   Folder: Sensor lead-field matrices (EEG, MEG, EIT, TES, gravity) and `zef_lead_field_matrix` dispatch on `core.types.ZefSourceModel`.
%
% Zef fields (observed):
%   zef.L (read)
%   zef.active_compartment_ind (read)
%   zef.bg_data (read)
%   zef.gravity_field_type (read, write)
%   zef.nodes (read)
%   zef.rho (read)
%   zef.sensors (read)
%   zef.source_directions (read)
%   zef.source_positions (read)
%   zef.tetra (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `warning('off');` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

warning('off');
zef.gravity_field_type = 4;
zef_delete_original_field;
zef_process_meshes;
[zef.L,  zef.bg_data, zef.source_positions, zef.source_directions] = lead_field_gravity(zef.nodes,zef.tetra,zef.rho,zef.sensors,zef.active_compartment_ind);
warning('on');
