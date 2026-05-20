function zef = zef_strip_tool_embed(zef)
% --- Zeffiro documentation header ---
% zef_strip_tool_embed — Zef strip tool embed.
%
% Purpose:
%   Zef strip tool embed.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.compartment_tags (read)
%   zef.current_sensors (read)
%   zef.strip_tool (read)
%
% Calls (project):
%   zef_add_compartment
%   zef_create_strip
%   zef_get_strip_parameters
%   zef_strip_coordinate_transform
%   zef_strip_tool_embed
%   zef_strip_tool_init
%   zef_strip_tool_update
%   zef_update_compartment_table_data
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_strip_tool_embed(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
