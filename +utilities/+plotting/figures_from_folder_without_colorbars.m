function figures_from_folder_without_colorbars(folder, filetypes, resolution)
% --- Zeffiro documentation header ---
% utilities.plotting.figures_from_folder_without_colorbars — Figures from folder without colorbars.
%
% Purpose:
%   Figures from folder without colorbars.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   folder
%   filetypes
%   resolution
%
% Outputs:
%   See function signature and code below.
%
% Calls (project):
%   utilities.plotting.figure_without_colorbar_fn
%   utilities.plotting.figures_from_folder_without_colorbars
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `utilities.plotting.figures_from_folder_without_colorbars(folder, filetypes, resolution)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    arguments

        folder (1,1) string { mustBeFolder }

        filetypes (:,1) string { mustBeMember(filetypes, [".pdf",".eps",".png"]) }

        resolution (1,1) double { mustBePositive }

    end

    file_structs = dir ( fullfile ( folder, "**", "*.fig" ) ) ;

    for si = 1 : numel ( file_structs )

        file_struct = file_structs ( si ) ;

        file_path = fullfile ( folder_fn ( file_struct ), name_fn ( file_struct ) ) ;

        [stem, name, ext] = fileparts ( file_path ) ;

        path_without_ext = fullfile ( stem, name ) ;

        fig = openfig ( file_path ) ;

        cleanup_fn = @(ff) close (ff) ;

        cleanup_obj = onCleanup ( @() cleanup_fn ( fig ) ) ;

        utilities.plotting.figure_without_colorbar_fn ( fig, path_without_ext, filetypes, resolution ) ;

    end

end % function

%% Helper functions

function name = name_fn(file_struct)
%NAME_FN Return the "name" field of a dir() struct as string.
    arguments
        file_struct (1,1) struct
    end
    if not ( isfield ( file_struct, "name" ) )
        error ( "The given file struct did not contain the field 'name'. Aborting..." ) ;
    end
    name = string ( file_struct.name ) ;
end % function

function folder = folder_fn(file_struct)
%FOLDER_FN Return the "folder" field of a dir() struct as string.
    arguments
        file_struct (1,1) struct
    end
    if not ( isfield ( file_struct, "folder" ) )
        error ( "The given file struct did not contain the field 'folder'. Aborting..." ) ;
    end
    folder = string ( file_struct.folder ) ;
end % function
