function abspaths = abspath ( files )
%ABSPATH Resolve file paths to absolute paths.
%
% ABSPATHS = ABSPATH(FILES) returns a string array of absolute, normalized
% paths for each file in FILES. Input paths may be relative or absolute;
% all returned paths are absolute and suitable for canonical reference.
%
% Input:
%   files  - (:,1) string, mustBeFile
%             List of paths to existing files (relative or absolute).
%
% Output:
%   abspaths - (:,1) string
%              Column vector of absolute paths, one per element of FILES.
%

    arguments

        files (:,1) string { mustBeFile }

    end

    fullpaths = fullfile ( files ) ;

    n_of_paths = numel ( fullpaths ) ;

    abspaths = repmat ( "", n_of_paths, 1 ) ;

    for ii = 1 : numel ( fullpaths )

        ff = fullpaths ( ii ) ;

        dd = dir ( ff ) ;

        folder = string ( dd.folder ) ;

        abspaths ( ii ) = fullfile ( folder, ff ) ;

    end

end % function
