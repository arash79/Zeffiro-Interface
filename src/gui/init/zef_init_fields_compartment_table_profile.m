%ZEF_INIT_FIELDS_COMPARTMENT_TABLE_PROFILE  Extra Segmentation-profile columns for one row (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Required workspace: zef, zef_i, zef_j, zef.aux_field_1.
%   For each parameter_profile row with Segmentation + On + On (columns
%   8, 6, 7), appends ColumnName from profile column 1 and writes
%   aux_field_1{zef_i, compartment_table_size+n} from
%   zef.<tag>_<profile{k,2}> (Scalar → num2str, String → as-is).
%
%   See also zef_init_fields_compartment_table, zef_init_parameter_profile.
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
