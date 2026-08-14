%ZEF_INIT_FIELDS_COMPARTMENT_TABLE  Fill one Segmentation-tool compartment row (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Required workspace: zef, zef_i (table row), zef_j (tag
%   index), zef.aux_field_1 (cell that becomes Data). Sets ColumnName /
%   Editable / Format for the first compartment_table_size columns, then
%   writes aux_field_1{zef_i,:} from compartment_tags{zef_j}:
%     1 Index          — zef_i
%     2 On             — *_on (logical)
%     3 Name           — *_name
%     4 Visible        — *_visible
%     5 Surface nodes  — size(*_points,1) (read-only)
%     6 Surface triangles — size(*_triangles,1) (read-only)
%     7 Merge          — *_merge
%     8 Invert normal  — *_invert
%     9 Activity       — compartment_activity{*_sources+2}
%       (Bounding box, Inactive, Constrained field, Unconstrained field,
%       Active surface). *_sources is stored as that list index minus 2.
%
%   See also zef_update_compartment_table_data,
%   zef_init_fields_compartment_table_profile.
zef.h_compartment_table.ColumnName(1:zef.compartment_table_size) =     {'Index','On','Name','Visible','Surface nodes','Surface triangles','Merge','Invert normal','Activity' };
zef.h_compartment_table.ColumnEditable(1:zef.compartment_table_size) = logical([1 1 1 1 0 0 1 1 1]);
zef.h_compartment_table.ColumnEditable(zef.compartment_table_size:end) = true;
zef.h_compartment_table.ColumnFormat(1:zef.compartment_table_size) = {'numeric','logical','char','logical','numeric','numeric','logical','logical',zef.compartment_activity};
zef.aux_field_1{zef_i,1} = zef_i;
zef.aux_field_1{zef_i,2}  = eval(['zef.' zef.compartment_tags{zef_j} '_on']);
zef.aux_field_1{zef_i,3}  = eval(['zef.' zef.compartment_tags{zef_j} '_name']);
zef.aux_field_1{zef_i,4}  = eval(['zef.' zef.compartment_tags{zef_j} '_visible']);
zef.aux_field_1{zef_i,5} = eval(['size(zef.' zef.compartment_tags{zef_j} '_points,1)']);
zef.aux_field_1{zef_i,6} = eval(['size(zef.' zef.compartment_tags{zef_j} '_triangles,1)']);
zef.aux_field_1{zef_i,7} = eval(['zef.' zef.compartment_tags{zef_j} '_merge']);
zef.aux_field_1{zef_i,8} = eval(['zef.' zef.compartment_tags{zef_j} '_invert']);
zef.aux_field_1{zef_i,9} = zef.h_compartment_table.ColumnFormat{9}{eval(['zef.' zef.compartment_tags{zef_j} '_sources'])+2};
