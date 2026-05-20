function zef = zef_apply_system_settings(zef)
% --- Zeffiro documentation header ---
% zef_apply_system_settings — Zef apply system settings.
%
% Purpose:
%   Zef apply system settings.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.ini_cell (read, write)
%   zef.ini_cell_mod (read)
%   zef.parallel_processes (read, write)
%   zef.program_path (read)
%   zef.segmentation_tool_default_position (read, write)
%
% Calls (project):
%   zef_apply_system_settings
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_apply_system_settings(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
