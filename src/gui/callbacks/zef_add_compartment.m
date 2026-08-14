function zef = zef_add_compartment(zef)
%ZEF_ADD_COMPARTMENT  Append one tissue row to the Segmentation compartment table.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   A compartment is a named tissue (scalp, skull, …) with its own surface
%   mesh and conductivity. This callback is how you add one from the GUI
%   after startup. Right-click the compartment UITable in the Segmentation
%   tool → **Add compartment** (uicontextmenu on h_compartment_table;
%   MenuSelectedFcn in zef_menu_tool is the string "zef_add_compartment;").
%
%   What it does
%     1. Snapshot the current table into zef.aux_field_1.
%     2. zef_compartment_tag picks the next unused tag c1, c2, …
%     3. zef_create_compartment writes zef.<tag>_* defaults (on, name
%        "Compartment N", sigma 0.33 S/m, empty points/triangles, …)
%        and appends the tag to zef.compartment_tags.
%     4. zef_init_fields_compartment_table fills the new table row;
%        zef_apply_parameter_profile / zef_init_fields_compartment_table_profile
%        add profile columns (σ, …).
%     5. Write Data back, drop aux_field_1, zef_update.
%
%   The new surface is empty until you right-click → **Import surface mesh**.
%   Then Mesh tool **Create FEM mesh** can include it if On is true.
%
%   zef = zef_add_compartment(zef)
%   zef_add_compartment          % nargout 0 → assignin base
%
%   Input / output
%     zef  - session. If omitted, evalin('base','zef').
%
%   See also zef_delete_compartment, zef_create_compartment, zef_update.

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
