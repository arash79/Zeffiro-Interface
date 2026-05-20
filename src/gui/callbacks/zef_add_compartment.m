function zef = zef_add_compartment(zef)
% --- Zeffiro documentation header ---
% zef_add_compartment — Zef add compartment.
%
% Purpose:
%   Zef add compartment.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.aux_field_1 (read, write)
%   zef.h_compartment_table (read)
%
% Calls (project):
%   zef_add_compartment
%   zef_apply_parameter_profile
%   zef_compartment_tag
%   zef_create_compartment
%   zef_update
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_add_compartment(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

zef.aux_field_1 = zef.h_compartment_table.Data;

zef = zef_create_compartment(zef,zef_compartment_tag(zef));
zef_i = size(zef.aux_field_1,1) + 1;
zef_j = 1;

zef_init_fields_compartment_table;
zef = zef_apply_parameter_profile(zef);

zef_i = size(zef.aux_field_1,1);
zef_j = 1;

zef_init_fields_compartment_table_profile;

zef.h_compartment_table.Data = zef.aux_field_1;

zef = rmfield(zef,'aux_field_1');
clear zef_i;

zef = zef_update(zef);

if nargout == 0
    assignin('base','zef',zef);
end

end
