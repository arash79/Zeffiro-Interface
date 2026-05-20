% --- Zeffiro documentation header ---
% zef.h_compartment_table.ColumnName(1:zef — Zef.h compartment table.Column Name(1:zef.
%
% Purpose:
%   Zef.h compartment table.Column Name(1:zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.aux_field_1 (read)
%   zef.compartment_activity (read)
%   zef.compartment_table_size (read)
%   zef.compartment_tags (read)
%   zef.h_compartment_table (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.h_compartment_table.ColumnName(1:zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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
