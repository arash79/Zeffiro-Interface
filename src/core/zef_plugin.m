%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% if isempty(zef — If isempty(zef.
%
% Purpose:
%   If isempty(zef.
%   Folder: Application lifecycle: `zef_start`, `zef_init`, `zef_update`, `zef_close_all`, logging, waitbars, window layout—not the `+core` package.
%
% Zef fields (observed):
%   zef.h_menu_1 (read, write)
%   zef.h_menu_2 (read, write)
%   zef.h_zeffiro_menu (read)
%   zef.plugin_cell (read, write)
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




if isempty(zef.plugin_cell)
    zef.plugin_cell = readcell([zef.program_path '/profile/' zef.profile_name '/zeffiro_plugins.ini'],'filetype','text','delimiter',',');
end
for zef_i = 1 : size(zef.plugin_cell,1)
    zef.h_menu_1 = findobj(zef.h_zeffiro_menu,'Tag',zef.plugin_cell{zef_i,2});
    if isempty(zef.h_menu_1) || ~isvalid(zef.h_menu_1)
        warning('Menu with Tag "%s" not found. Skipping plugin "%s".', zef.plugin_cell{zef_i,2}, zef.plugin_cell{zef_i,1});
        continue;
    end
    zef.h_menu_2 = findobj(zef.h_menu_1.Children,'label',zef.plugin_cell{zef_i,1});
    if not(isempty(zef.h_menu_2))
        set(zef.h_menu_2,'Callback',[zef.plugin_cell{zef_i,3} '; zef_update;']);
    else
        zef.h_menu_2 = uimenu(zef.h_menu_1,'label',zef.plugin_cell{zef_i,1},'callback',[zef.plugin_cell{zef_i,3} '; zef_update;'] );
    end
end
clear zef_i;
zef = rmfield(zef,{'h_menu_1','h_menu_2'});
