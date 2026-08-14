function zef = zef_apply_system_settings(zef)
%ZEF_APPLY_SYSTEM_SETTINGS  Merge profile/zeffiro_interface.ini into missing zef fields.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Settings → **System settings (zeffiro_interface.ini)**. The window's
%   Apply control (h_system_settings_apply) runs zef_save_system_settings
%   then this function. Also called from zef_start and zef_load (existing
%   zef fields win; only missing names are filled).
%
%   zef = zef_apply_system_settings(zef)
%   zef_apply_system_settings          % nargout 0 → assignin base
%
%   Input
%     zef  - session. Omitted → evalin('base','zef').
%
%   What it does
%     1. readcell program_path/profile/zeffiro_interface.ini.
%        Column 4 'number' → str2num if needed; 'string' → num2str.
%        Column 3 is the zef field name; column 2 the value. Assigned
%        only if not already isfield.
%     2. Drops ini_cell. If ini_cell_mod exists, same loop then rmfield
%        (string branch writes ini_cell{i,2} and stores num2str of the
%        mod value).
%     3. If segmentation_tool_default_position is [0 0 0 0], sets it from
%        groot ScreenSize.
%     4. Caps parallel_processes at maxNumCompThreads.
%
%   See also zef_system_settings_table_selection, zef_start, zef_save_system_settings.

if nargin == 0
    zef = evalin('base','zef');
end


zef.ini_cell = readcell([zef.program_path '/profile/zeffiro_interface.ini'],'FileType','text');
for zef_i =  1 : size(zef.ini_cell,1)
    if isequal(zef.ini_cell{zef_i,4},'number')
        if not(isnumeric(zef.ini_cell{zef_i,2}))
            zef.ini_cell{zef_i,2} = str2num(zef.ini_cell{zef_i,2});
        end
    elseif isequal(zef.ini_cell{zef_i,4},'string')
        zef.ini_cell{zef_i,2} = num2str(zef.ini_cell{zef_i,2});
    end

    if not(isfield(zef,zef.ini_cell{zef_i,3}))
    zef.(zef.ini_cell{zef_i,3})  = zef.ini_cell{zef_i,2};
    end

end

zef = rmfield(zef,'ini_cell');
if isfield(zef,'ini_cell_mod')
    for zef_i =  1 : size(zef.ini_cell_mod,1)
        if isequal(zef.ini_cell_mod{zef_i,4},'number')
            if not(isnumeric(zef.ini_cell_mod{zef_i,2}))
                zef.ini_cell_mod{zef_i,2} = str2num(zef.ini_cell_mod{zef_i,2});
            end
        elseif isequal(zef.ini_cell_mod{zef_i,4},'string')
            zef.ini_cell{zef_i,2} = num2str(zef.ini_cell_mod{zef_i,2});
        end

         if not(isfield(zef,zef.ini_cell_mod{zef_i,3}))
        zef.(zef.ini_cell_mod{zef_i,3})  =  num2str(zef.ini_cell_mod{zef_i,2});
         end

    end
    zef = rmfield(zef,'ini_cell_mod');
end

if isequal(zef.segmentation_tool_default_position,[0 0 0 0])
    h_groot = groot;
    screen_size = h_groot.ScreenSize;
    zef.segmentation_tool_default_position = [screen_size(3)/25 775*screen_size(4)/2250 8*screen_size(3)/27 5*screen_size(4)/9];
end

if zef.parallel_processes > maxNumCompThreads
zef.parallel_processes = maxNumCompThreads;
end

if nargout == 0
    assignin('base','zef',zef);
end

end
