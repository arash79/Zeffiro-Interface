%ZEF_GRAVITY_GRADIENT_LEAD_FIELD_VECTOR  Asteroid INI script: vector gravity gradient.
%
%   Zeffiro Interface.
%   Copyright © 2018, Sampsa Pursiainen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%
%   Script (not a function). Mesh-tool row "Gravity gradient (vector)" in
%   profile/asteroid_gravity and profile/asteroid_radar. Same sequence as
%   zef_gravity_gradient_lead_field_scalar with gravity_field_type = 2.
%   Still calls lead_field_gravity_grad; the scalar vs vector split is that
%   flag, not a second FEM file. Type 2 writes zef.L with 3 rows per
%   station (3*n_stations × n_sources) from two 1/r^3–1/r^5 terms along
%   sensors(:,4:6). Density is zef.rho. Does not call zef_lead_field_matrix.
%
%   See also zef_lead_field_gravity_grad, zef_gravity_gradient_lead_field_scalar.

warning('off');
zef.gravity_field_type = 2;
zef_delete_original_field;
zef_process_meshes;
[zef.L,  zef.bg_data, zef.source_positions, zef.source_directions] = lead_field_gravity_grad(zef.nodes,zef.tetra,zef.rho,zef.sensors,zef.active_compartment_ind);
warning('on');
