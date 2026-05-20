% --- Zeffiro documentation header ---
% eval(['zef.' zef.compartment_tags{zef_j}, '_on = ' num2str(double(zef — Eval(['zef.' zef.compartment tags{zef j}, ' on = ' num2str(double(zef.
%
% Purpose:
%   Eval(['zef.' zef.compartment tags{zef j}, ' on = ' num2str(double(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.aux_field_1 (read)
%   zef.compartment_tags (read)
%   zef.h_compartment_table (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `eval(['zef.' zef.compartment_tags{zef_j}, '_on = ' num2str(double(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

eval(['zef.' zef.compartment_tags{zef_j}, '_on = ' num2str(double(zef.aux_field_1{zef_i,2})) ';']);
eval(['zef.' zef.compartment_tags{zef_j}, '_name = ''' zef.aux_field_1{zef_i,3} ''';']);
eval(['zef.' zef.compartment_tags{zef_j}, '_visible = ' num2str(double(zef.aux_field_1{zef_i,4})) ';']);
eval(['zef.' zef.compartment_tags{zef_j}, '_merge = ' num2str(double(zef.aux_field_1{zef_i,7})) ';']);
eval(['zef.' zef.compartment_tags{zef_j}, '_invert = ' num2str(double(zef.aux_field_1{zef_i,8})) ';']);
eval(['zef.' zef.compartment_tags{zef_j}, '_sources = ' num2str(find(ismember(zef.h_compartment_table.ColumnFormat{9},zef.aux_field_1{zef_i,9}),1)-2) ';']);
