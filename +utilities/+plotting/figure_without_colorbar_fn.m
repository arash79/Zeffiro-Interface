function figure_without_colorbar_fn(figtool, filename, filetypes, resolution)
% --- Zeffiro documentation header ---
% utilities.plotting.figure_without_colorbar_fn — Figure without colorbar fn.
%
% Purpose:
%   Figure without colorbar fn.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   figtool
%   filename
%   filetypes
%   resolution
%
% Outputs:
%   See function signature and code below.
%
% Calls (project):
%   utilities.plotting.figure_without_colorbar_fn
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `utilities.plotting.figure_without_colorbar_fn(figtool, filename, filetypes, resolution)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    arguments

        figtool (1,1) matlab.ui.Figure

        filename (1,1) string

        filetypes (:,1) string { mustBeMember( filetypes, [".pdf", ".eps", ".png"] ) }

        resolution (1,1) double { mustBePositive } = 400

    end

    if strlength ( filename ) == 0
        error ( "A filename must not be empty. Call this function with a valid filename as the 2nd argument." ) ;
    end

    % Hide all colorbars in the figure before export.
    cbars = findobj ( figtool, "Type", "colorbar" ) ;

    for bi = 1 : numel ( cbars )

        cbar = cbars ( bi ) ;

        cbar.Visible = false ;

    end

    for si = 1 : numel ( filetypes )

        suffix = filetypes ( si ) ;

        exportgraphics ( figtool, filename + suffix, "Resolution", resolution) ;

    end

end % function
