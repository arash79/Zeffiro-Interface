function  zef_close_all(zef)
%ZEF_CLOSE_ALL  Close Zeffiro figures, restore window defaults, and clear session vars.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Finds every figure whose Name matches "ZEFFIRO Interface*", disables
%   DeleteFcn so close callbacks do not re-enter teardown, deletes those
%   figures, deletes the waitbar, and restores MATLAB figure WindowStyle
%   via zef_window_manager('restore'). Unless zef.zeffiro_restart is 1,
%   the Zeffiro tree is then rmpath'd. Always clears zef, zef_data, and
%   index helpers from the base workspace.
%
%   zef_close_all
%   zef_close_all(zef)
%
%   Input
%     zef  - optional session struct. If omitted, taken from the base
%            workspace when it exists. Used only to decide whether a
%            restart should skip rmpath.
%
%   Side effects
%     Deletes GUI figures, mutates the MATLAB path, clears base-workspace
%     variables zef, zef_data, zef_i, zef_j, zef_k.
%
%   See also zeffiro_interface, zef_start, zef_window_manager.


if nargin == 0
    if evalin('base','exist(''zef'',''var'')')
        zef = evalin('base','zef');
    end
end

zef.h_window_aux = findall(groot,'-regexp','Name','ZEFFIRO Interface*');
set(zef.h_window_aux,'DeleteFcn','');
delete(zef.h_window_aux);
zef_delete_waitbar;
% zeffiro_interface adds only src/app before this call on a cold start.
% Restore is a no-op until zef_window_manager has been on the path.
if exist('zef_window_manager', 'file') == 2
    zef_window_manager('restore');
end
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
