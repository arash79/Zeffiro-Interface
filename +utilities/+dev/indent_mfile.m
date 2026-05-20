function indent_mfile ( filename )
% --- Zeffiro documentation header ---
% utilities.dev.indent_mfile — Indent mfile.
%
% Purpose:
%   Indent mfile.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   filename
%
% Outputs:
%   See function signature and code below.
%
% Calls (project):
%   utilities.dev.indent_mfile
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `utilities.dev.indent_mfile(filename)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
