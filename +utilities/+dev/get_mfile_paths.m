function mfiles = get_mfile_paths(folder)
% --- Zeffiro documentation header ---
% utilities.dev.get_mfile_paths — Get mfile paths.
%
% Purpose:
%   Get mfile paths.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   folder
%
% Outputs:
%   mfiles
%
% Calls (project):
%   utilities.dev.get_mfile_paths
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[mfiles] = utilities.dev.get_mfile_paths(folder)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
