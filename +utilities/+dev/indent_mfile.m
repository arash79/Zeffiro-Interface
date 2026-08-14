function indent_mfile ( filename )
%INDENT_MFILE  Open one .m file in the editor, smart-indent, and save.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   indent_mfile(filename)
%
%   Resolves filename with which(), opens in matlab.desktop.editor, calls
%   smartIndentContents(), saves, and closes on cleanup.

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
