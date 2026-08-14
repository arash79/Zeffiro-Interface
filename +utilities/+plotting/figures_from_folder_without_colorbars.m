function figures_from_folder_without_colorbars(folder, filetypes, resolution)
%FIGURES_FROM_FOLDER_WITHOUT_COLORBARS  Batch-export .fig files without colorbars.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   figures_from_folder_without_colorbars(folder, filetypes, resolution)
%
%   Recursively finds *.fig under folder, opens each, and calls
%   figure_without_colorbar_fn with the stem path and requested formats.

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
