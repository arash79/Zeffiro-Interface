function indent_mfiles(folder)
% --- Zeffiro documentation header ---
% utilities.dev.indent_mfiles — Indent mfiles.
%
% Purpose:
%   Indent mfiles.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   folder
%
% Outputs:
%   See function signature and code below.
%
% Calls (project):
%   utilities.dev.get_mfile_paths
%   utilities.dev.indent_mfile
%   utilities.dev.indent_mfiles
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `utilities.dev.indent_mfiles(folder)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    arguments

        folder (1,1) string { mustBeFolder }

    end

    mfile_paths = utilities.dev.get_mfile_paths( folder ) ;

    for fi = 1 : numel ( mfile_paths )

        fp = mfile_paths ( fi ) ;

        utilities.dev.indent_mfile ( fp ) ;

    end % for

end % function
