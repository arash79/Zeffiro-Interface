function indent_mfiles(folder)
%INDENT_MFILES Apply smart indentation to all .m files under a folder.
%
% indent_mfiles(FOLDER) discovers every .m file in FOLDER and its
% subdirectories (via utilities.get_mfile_paths), then runs
% utilities.indent_mfile on each. Requires MATLAB to be run with Java
% enabled (not -nodesktop).
%
% Input:
%   folder - (1,1) string, mustBeFolder
%            Root directory to search for .m files.
%
% Outputs:
%   None.
%

    arguments

        folder (1,1) string { mustBeFolder }

    end

    mfile_paths = utilities.get_mfile_paths( folder ) ;

    for fi = 1 : numel ( mfile_paths )

        fp = mfile_paths ( fi ) ;

        utilities.indent_mfile ( fp ) ;

    end % for

end % function
