%Copyright © 2018- Joonas Lahtinen, Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% function SESAME_core_check — Function SESAME core check.
%
% Purpose:
%   Function SESAME core check.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.program_path (read)
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function SESAME_core_check` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

%This script checks if the core script of SESAME, 'inverse_SESAME.m', is
%already downloaded. If not, it write a .m script based on the raw form
%from the FGitHub link:
%https://raw.githubusercontent.com/i-am-sorri/SESAME_core/master/inverse_SESAME.m

function SESAME_core_check

program_path = evalin("base","zef.program_path");

if ~isfile(fullfile(program_path,'tools','plugins','SESAME','m','inverse_SESAME.m'))
    SESAME_script = webread("https://raw.githubusercontent.com/i-am-sorri/SESAME_core/master/inverse_SESAME.m");
    filename = fullfile(program_path,'tools','plugins','SESAME','m','inverse_SESAME.m');
    file_id = fopen(filename,'w');
    fprintf(file_id,'%s',SESAME_script);
    fclose(file_id);
end

end
