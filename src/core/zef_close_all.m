function  zef_close_all(zef)
% --- Zeffiro documentation header ---
% zef_close_all — Zef close all.
%
% Purpose:
%   Zef close all.
%   Folder: Application lifecycle: `zef_start`, `zef_init`, `zef_update`, `zef_close_all`, logging, waitbars, window layout—not the `+core` package.
%
% Inputs:
%   zef
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.h_window_aux (read, write)
%   zef.zeffiro_restart (read)
%
% Calls (project):
%   zef_close_all
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_close_all(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    if evalin('base','exist(''zef'',''var'')')
        zef = evalin('base','zef');
    end
end

zef.h_window_aux = findall(groot,'-regexp','Name','ZEFFIRO Interface*');
%zef.h_window_aux = findall(groot,'-property','ZefTool','-or','-property','ZefFig');
set(zef.h_window_aux,'DeleteFcn','');
delete(zef.h_window_aux);
zef_delete_waitbar;
if exist('zef','var')
    if isfield(zef,'zeffiro_restart')
        if isequal(zef.zeffiro_restart,0)
            warning('off','MATLAB:rmpath:DirNotFound');
            rmpath(genpath(fileparts(which('zeffiro_interface.m'))));
            warning('on','MATLAB:rmpath:DirNotFound');
        end
    else
        warning('off','MATLAB:rmpath:DirNotFound');
        rmpath(genpath(fileparts(which('zeffiro_interface.m'))));
        warning('on','MATLAB:rmpath:DirNotFound');
    end
else
    warning('off','MATLAB:rmpath:DirNotFound');
    rmpath(genpath(fileparts(which('zeffiro_interface.m'))));
    warning('on','MATLAB:rmpath:DirNotFound');
end

evalin('base','clear zef zef_data zef_i zef_j zef_k;');

end
