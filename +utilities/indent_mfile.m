function indent_mfile ( filename )
%INDENT_MFILE Apply smart indentation to a single MATLAB source file.
%
% indent_mfile(FILENAME) opens the given .m file in the editor (by resolving
% it via which()), runs smartIndentContents(), saves, and closes the document.
% Requires MATLAB to be run with Java enabled (not -nodesktop).
%
% Input:
%   filename - (1,1) string, mustBeFile
%               Path or name of the .m file to indent (must be on path).
%
% Outputs:
%   None.
%

    arguments

        filename (1,1) string { mustBeFile }

    end

    fullpath = which ( filename ) ;

    fh = matlab.desktop.editor.openDocument ( fullpath ) ;

    cleanup_object = onCleanup( @() cleanup_fn ( fh ) );

    fh.smartIndentContents() ;

    fh.save() ;

end % function

%% Helper functions

function cleanup_fn(document)
    document.close() ;
end % function
