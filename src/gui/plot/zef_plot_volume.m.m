% --- Zeffiro documentation header ---
% if not(isequal(zef — If not(isequal(zef.
%
% Purpose:
%   If not(isequal(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.aux_field (read, write)
%   zef.current_sensors (read)
%   zef.file (read)
%   zef.file_path (read)
%
% Calls (project):
%   zef_get_mesh
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if not(isequal(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

if not(isequal(zef.file,0));
    zef.aux_field = zef_get_mesh(zef,[zef.file_path zef.file],zef.current_sensors,'points');
    eval(['zef.' zef.current_sensors '_points = zef.aux_field;']);
    zef = rmfield(zef,'aux_field');
end;
