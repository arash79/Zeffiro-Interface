% --- Zeffiro documentation header ---
% zef_data — Zef data.
%
% Purpose:
%   Zef data.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef_data` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef_data.fieldnames = fieldnames(zef_data);
zef_data.remove_fieldnames = cell(0);
zef_j = 0;
for zef_i = 1 : length(zef_data.fieldnames)
    if isobject(eval(['zef_data.' zef_data.fieldnames{zef_i}]))
        zef_j = zef_j + 1;
        zef_data.remove_fieldnames{zef_j} = zef_data.fieldnames{zef_i};
    end
end
zef_data = rmfield(zef_data,zef_data.remove_fieldnames);
zef_data = rmfield(zef_data,{'remove_fieldnames','fieldnames'});
clear zef_i zef_j
