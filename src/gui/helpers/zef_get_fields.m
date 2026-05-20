function zef_data = zef_get_fields(fieldnames_aux, zef)
% --- Zeffiro documentation header ---
% zef_get_fields — Zef get fields.
%
% Purpose:
%   Zef get fields.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   fieldnames_aux
%   zef
%
% Outputs:
%   zef_data
%
% Calls (project):
%   zef_get_fields
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef_data] = zef_get_fields(fieldnames_aux, zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if nargin == 1
    zef = evalin('base','zef');
end

zef_data = struct;
for zef_i = 1 : length(fieldnames_aux)
    zef_data.(fieldnames_aux{zef_i}) = zef_data.(fieldnames_aux{zef_i});
end

end
