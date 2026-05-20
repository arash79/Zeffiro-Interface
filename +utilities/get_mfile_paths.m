function mfiles = get_mfile_paths(folder)
%GET_MFILE_PATHS List all .m file paths under a folder recursively.
%
% MFILES = get_mfile_paths(FOLDER) returns a string array of full paths to
% every .m file in FOLDER and its subdirectories. Order follows dir().
%
% Input:
%   folder - (1,1) string, mustBeFolder
%            Root directory to search.
%
% Output:
%   mfiles - (:,1) string
%            Full path of each discovered .m file.
%

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
