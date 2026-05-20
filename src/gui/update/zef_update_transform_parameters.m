% --- Zeffiro documentation header ---
% zef.aux_field_1 = zef.h_parameters_table — Zef.aux field 1 = zef.h parameters table.
%
% Purpose:
%   Zef.aux field 1 = zef.h parameters table.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.aux_field_1 (read)
%   zef.aux_field_2 (read, write)
%   zef.current_tag (read)
%   zef.current_transform (read)
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.aux_field_1 = zef.h_parameters_table` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.aux_field_1 = zef.h_parameters_table.Data;
zef.aux_field_2 = {'scaling','x_correction','y_correction','z_correction','xy_rotation','yz_rotation','zx_rotation','affine_transform'};

for zef_i = 1 : size(zef.aux_field_1,1)

    if numel(str2num(zef.aux_field_1{zef_i,2})) > 1
        evalin('base',['zef.' zef.current_tag '_' zef.aux_field_2{zef_i} '(' num2str(zef.current_transform) ')= {[' zef.aux_field_1{zef_i,2} ']};']);
    else
        evalin('base',['zef.' zef.current_tag '_' zef.aux_field_2{zef_i} '(' num2str(zef.current_transform) ')=' zef.aux_field_1{zef_i,2} ';']);
    end

end

zef = rmfield(zef,{'aux_field_1','aux_field_2'});
clear zef_i;
