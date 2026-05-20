function abspaths = abspath ( files )
% --- Zeffiro documentation header ---
% utilities.io.abspath — Abspath.
%
% Purpose:
%   Abspath.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   files
%
% Outputs:
%   abspaths
%
% Calls (project):
%   utilities.io.abspath
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[abspaths] = utilities.io.abspath(files)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
