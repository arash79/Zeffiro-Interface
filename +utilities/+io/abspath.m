function abspaths = abspath ( files )
%ABSPATH  Resolve file paths to absolute paths via dir().
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   abspaths = abspath(files)
%
%   files is a column vector of existing file paths (string). Returns the same
%   count of absolute paths built from each file's dir().folder and name.

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
