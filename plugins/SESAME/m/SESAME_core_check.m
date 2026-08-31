function SESAME_core_check
%SESAME_CORE_CHECK  Download inverse_SESAME.m from SESAME_core if missing.
%
%   Copyright © 2018- Joonas Lahtinen, Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from SESAME_App_run. Reads zef.program_path from base.
%   webread i-am-sorri/SESAME_core inverse_SESAME.m into this folder.
%   No-op when the file already exists.
%
%   See also inverse_SESAME, SESAME_App_run.

program_path = evalin("base","zef.program_path");

if ~isfile(fullfile(program_path,'plugins','SESAME','m','inverse_SESAME.m'))
    SESAME_script = webread("https://raw.githubusercontent.com/i-am-sorri/SESAME_core/master/inverse_SESAME.m");
    filename = fullfile(program_path,'plugins','SESAME','m','inverse_SESAME.m');
    file_id = fopen(filename,'w');
    fprintf(file_id,'%s',SESAME_script);
    fclose(file_id);
end

end
