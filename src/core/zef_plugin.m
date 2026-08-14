%ZEF_PLUGIN  Wire profile plugin entries into the Zeffiro menu tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Reads profile/<profile_name>/zeffiro_plugins.ini (CSV) when
%   zef.plugin_cell is empty. Each row is {label, parent menu Tag, callback}.
%   Existing matching uimenu items get their Callback replaced; otherwise a
%   child uimenu is created. Temporary handles h_menu_1/h_menu_2 are removed
%   from zef afterwards.
%
%   Workspace
%     zef  - session with h_zeffiro_menu, program_path, profile_name.
%
%   Notes
%     Warns and skips a row when the parent Tag is missing. Callback strings
%     always append "; zef_update;".
%
%   See also zef_menu_tool, zef_update.

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
