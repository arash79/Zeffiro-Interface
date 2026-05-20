% --- Zeffiro documentation header ---
% if isempty(zef — If isempty(zef.
%
% Purpose:
%   If isempty(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.init_profile (read, write)
%   zef.profile_name (read)
%   zef.program_path (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if isempty(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

if isempty(zef.init_profile)
    zef.init_profile = readcell([zef.program_path '/profile/' zef.profile_name '/zeffiro_init.ini'],'filetype','text','delimiter',',');
end
zef_init_init_profile;
