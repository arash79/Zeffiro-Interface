function mfiles = get_mfile_paths(folder)
%GET_MFILE_PATHS  Recursive dir of *.m under folder (full paths).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Developer helper for indent_mfiles / lint_mfiles. folder must exist.
%   Returns a string array of fullfile(folder,name) for every match,
%   including this tree's tests and plugins if you point at the repo root.
%
%   mfiles = get_mfile_paths(folder)

    arguments

        folder (1,1) string { mustBeFolder }

    end

    m_file_structs = dir ( fullfile ( folder, '**/*.m' ) ) ;

    mfiles = string ( arrayfun ( @path_fn, m_file_structs, UniformOutput=false ) ) ;

end % function

%% Helper functions

function name = path_fn(file_struct)
%PATH_FN Build full path from a dir() struct (folder + name).
    arguments
        file_struct (1,1) struct
    end
    name = string ( fullfile ( file_struct.folder, file_struct.name ) ) ;
end % function
