%ZEF_GRAVITY_LEAD_FIELD_SCALAR  Asteroid-profile script: scalar gravity (type 3).
%
%   Zeffiro Interface.
%   Copyright © 2018, Sampsa Pursiainen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%
%   Script. Mesh-tool INI row in profile/asteroid_gravity (and asteroid_radar).
%   Sets gravity_field_type=3, process_meshes, then lead_field_gravity with
%   density zef.rho (not sigma). Writes zef.L, zef.bg_data, source_positions,
%   source_directions. Does not call zef_lead_field_matrix.
%
%   See also zef_lead_field_gravity, zef_run_forward_simulation.

warning('off');
zef.gravity_field_type = 3;
zef_delete_original_field;
zef_process_meshes;
[zef.L,  zef.bg_data, zef.source_positions, zef.source_directions] = zef_lead_field_gravity(zef.nodes,zef.tetra,zef.rho,zef.sensors,zef.active_compartment_ind);
warning('on');
