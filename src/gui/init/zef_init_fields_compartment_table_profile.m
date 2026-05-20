% --- Zeffiro documentation header ---
% zef_n = 0; — Zef n = 0;.
%
% Purpose:
%   Zef n = 0;.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.aux_field_1 (read)
%   zef.compartment_table_size (read)
%   zef.compartment_tags (read)
%   zef.h_compartment_table (read)
%   zef.parameter_profile (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef_n = 0;` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef_n = 0;
for zef_k =  1  : size(zef.parameter_profile,1)
    if isequal(zef.parameter_profile{zef_k,8},'Segmentation') && isequal(zef.parameter_profile{zef_k,6},'On') && isequal(zef.parameter_profile{zef_k,7},'On')
        zef_n = zef_n + 1;
        zef.h_compartment_table.ColumnName{zef_n+zef.compartment_table_size} = zef.parameter_profile{zef_k,1};
        if isequal(zef.parameter_profile{zef_k,3},'Scalar')
            zef.aux_field_1{zef_i,zef_n+zef.compartment_table_size} = num2str(eval(['zef.' zef.compartment_tags{zef_j} '_' zef.parameter_profile{zef_k,2}]));
        elseif isequal(zef.parameter_profile{zef_k,3},'String')
            zef.aux_field_1{zef_i,zef_n + zef.compartment_table_size} = (eval(['zef.' zef.compartment_tags{zef_j} '_' zef.parameter_profile{zef_k,2}]));
        end
    end
end
