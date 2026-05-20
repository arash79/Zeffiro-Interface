% --- Zeffiro documentation header ---
% zef — Zef.
%
% Purpose:
%   Zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.aux_data_1 (read)
%   zef.aux_data_2 (read, write)
%   zef.current_tag (read)
%   zef.h_transform_table (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.aux_data_1 = cell(0);
zef.aux_data_2 = eval(['zef.' zef.current_tag '_transform_name']);

for zef_i = 1 : length(zef.aux_data_2)
    zef.aux_data_1{zef_i,1} = zef_i;
    zef.aux_data_1{zef_i,2} = zef.aux_data_2{zef_i};
end

zef.h_transform_table.Data = zef.aux_data_1;

zef = rmfield(zef,{'aux_data_1','aux_data_2'});
clear zef_i;
