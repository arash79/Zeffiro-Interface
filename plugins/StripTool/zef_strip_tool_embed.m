function zef = zef_strip_tool_embed(zef)
%ZEF_STRIP_TOOL_EMBED  Add current strip as mesh compartments.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_create_strip + coordinate transform; zef_add_compartment for the
%   strip and optional encapsulation. Sets strip_status to 'Embedded'.
%
%   zef = zef_strip_tool_embed(zef)
%

cell_aux = zef.([zef.current_sensors '_strip_cell']);

strip_struct = zef_get_strip_parameters(cell_aux{zef.strip_tool.current_strip});
[strip_struct] = zef_create_strip(strip_struct);
points = zef_strip_coordinate_transform(strip_struct,'forward');

strip_struct.compartment_tag = cell(0);

if strip_struct.encapsulation_on 

zef = zef_add_compartment(zef);
strip_struct.compartment_tag{2} = zef.compartment_tags{1};
zef.([zef.compartment_tags{1} '_name']) =  ['Encapsulation, ID: ' num2str(strip_struct.strip_id) ', Tag: ' strip_struct.strip_tag ', Model: ' zef.strip_tool.h_strip_model.String{strip_struct.strip_model} ];
zef.([zef.compartment_tags{1} '_triangles']) = strip_struct.triangles{2};
zef.([zef.compartment_tags{1} '_submesh_ind']) = size(strip_struct.triangles{2},1);
zef.([zef.compartment_tags{1} '_points']) = points{2};
zef.([zef.compartment_tags{1} '_sigma']) = strip_struct.encapsulation_conductivity;
zef = zef_update_compartment_table_data(zef);

end

zef = zef_add_compartment(zef);
strip_struct.compartment_tag{1} = zef.compartment_tags{1};
zef.([zef.compartment_tags{1} '_name']) =  ['Strip, ID: ' num2str(strip_struct.strip_id) ', Tag: ' strip_struct.strip_tag ', Model: ' zef.strip_tool.h_strip_model.String{strip_struct.strip_model} ];
zef.([zef.compartment_tags{1} '_triangles']) = strip_struct.triangles{1};
zef.([zef.compartment_tags{1} '_submesh_ind']) = size(strip_struct.triangles{1},1);
zef.([zef.compartment_tags{1} '_points']) = points{1};
zef.([zef.compartment_tags{1} '_sigma']) = strip_struct.strip_conductivity;

zef = zef_update_compartment_table_data(zef);

strip_struct.strip_status = 'Embedded';

cell_aux{zef.strip_tool.current_strip} = strip_struct;
zef.([zef.current_sensors '_strip_cell']) = cell_aux;

zef = zef_strip_tool_init(zef);
zef = zef_strip_tool_update(zef);

end
