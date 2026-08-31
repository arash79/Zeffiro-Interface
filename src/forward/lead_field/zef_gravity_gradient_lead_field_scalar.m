%ZEF_GRAVITY_GRADIENT_LEAD_FIELD_SCALAR  Asteroid INI script: scalar gravity gradient.
%
%   Zeffiro Interface.
%   Copyright © 2018, Sampsa Pursiainen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%
%   Script (not a function). Mesh-tool forward-simulation table row
%   "Gravity gradient (scalar)" in profile/asteroid_gravity and
%   profile/asteroid_radar (zeffiro_forward_simulation.ini). Sets
%   zef.gravity_field_type = 1, zef_delete_original_field,
%   zef_process_meshes, then lead_field_gravity_grad (file
%   zef_lead_field_gravity_grad) with density zef.rho (not sigma) and
%   zef.active_compartment_ind. Writes zef.L (n_stations × n_sources),
%   zef.bg_data, source_positions, source_directions. Does not call
%   zef_lead_field_matrix. Type 1 uses sensors(:,1:3) and unit
%   sensors(:,4:6) with a 1/r^4 directional kernel (see the FEM file).
%
%   See also zef_lead_field_gravity_grad, zef_gravity_gradient_lead_field_vector.

warning('off');
zef.gravity_field_type = 1;
zef_delete_original_field;
zef_process_meshes;
[zef.L,  zef.bg_data, zef.source_positions, zef.source_directions] = zef_lead_field_gravity_grad(zef.nodes,zef.tetra,zef.rho,zef.sensors,zef.active_compartment_ind);
warning('on');
