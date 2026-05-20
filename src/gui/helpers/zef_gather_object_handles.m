function h_struct = zef_gather_object_handles(zef,window_name)
% --- Zeffiro documentation header ---
% zef_gather_object_handles — Zef gather object handles.
%
% Purpose:
%   Zef gather object handles.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%   window_name
%
% Outputs:
%   h_struct
%
% Calls (project):
%   zef_find_object_handles
%   zef_gather_object_handles
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[h_struct] = zef_gather_object_handles(zef, window_name)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 1
    window_name = 'ZEFFIRO Interface';
end

h_groot = findall(groot,'-regexp','Name',window_name);
h_struct = zef_find_object_handles(zef, h_groot);

fields = fieldnames(h_struct);

for i = 1 : length(fields)
    if ismember('Children',properties(h_struct.(fields{i})))
        h_struct_aux = zef_find_object_handles(zef, cat(1,h_struct.(fields{i}).Children));
        h_struct.(fields{i}) = h_struct_aux;
    end
end

end
