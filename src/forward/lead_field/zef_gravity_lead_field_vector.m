%ZEF_GRAVITY_LEAD_FIELD_VECTOR  Asteroid-profile script: vector gravity (type 4).
%
%   Zeffiro Interface.
%   Copyright © 2018, Sampsa Pursiainen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%
%   Script. Same as zef_gravity_lead_field_scalar with gravity_field_type=4.
%   Still calls lead_field_gravity (the vector vs scalar distinction is the
%   type flag stored on zef, not a different FEM file).
%
%   See also zef_lead_field_gravity, zef_gravity_lead_field_scalar.

warning('off');
zef.gravity_field_type = 4;
zef_delete_original_field;
zef_process_meshes;
[zef.L,  zef.bg_data, zef.source_positions, zef.source_directions] = lead_field_gravity(zef.nodes,zef.tetra,zef.rho,zef.sensors,zef.active_compartment_ind);
warning('on');
