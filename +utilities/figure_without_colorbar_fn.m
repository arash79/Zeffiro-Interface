function figure_without_colorbar_fn(figtool, filename, filetypes, resolution)
%FIGURE_WITHOUT_COLORBAR_FN Export Zeffiro Figure tool without colorbar(s).
%
% figure_without_colorbar_fn(FIGTOOL, FILENAME, FILETYPES, RESOLUTION) hides
% all colorbars in the given Zeffiro Interface Figure tool, then exports the
% figure to the specified file formats (.pdf, .eps, .png) using the given
% resolution for raster formats.
%
% Inputs:
%   figtool    - (1,1) matlab.ui.Figure
%                 Handle to the Zeffiro Interface Figure tool.
%   filename   - (1,1) string, non-empty
%                 Base filename for output (no extension).
%   filetypes  - (:,1) string, mustBeMember([".pdf", ".eps", ".png"])
%                 File extensions to export (e.g. [".pdf"; ".png"]).
%   resolution - (1,1) double, mustBePositive, default 400
%                 Resolution (DPI) for image export (e.g. PNG).
%
% Outputs:
%   None. Figure is exported to FILENAME.<ext> for each element of FILETYPES.
%

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
