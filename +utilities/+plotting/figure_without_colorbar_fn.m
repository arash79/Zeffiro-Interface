function figure_without_colorbar_fn(figtool, filename, filetypes, resolution)
%FIGURE_WITHOUT_COLORBAR_FN  Export figure with all colorbars hidden.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   figure_without_colorbar_fn(figtool, filename, filetypes, resolution)
%
%   Hides every colorbar on figtool, then exportgraphics to filename+suffix for
%   each of filetypes (.pdf, .eps, .png). resolution defaults to 400 DPI.

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
