function colorbar_from_figtool_fn(figtool, filename_without_suffix, filetypes, kwargs)
%COLORBAR_FROM_FIGTOOL_FN  Export standalone colorbar from Zeffiro Figure tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   colorbar_from_figtool_fn(figtool, filename_without_suffix, filetypes, kwargs)
%
%   Reads limits from the rightColorbar tag on figtool, builds a minimal figure
%   with five tick marks, and exportgraphics to each filetypes entry (.png,
%   .pdf, .eps). kwargs: colormap, fontsize (20), resolution (400), decplaces (1).

    arguments

        figtool (1,1) matlab.ui.Figure

        filename_without_suffix (1,1) string { mustBeValidVariableName }

        filetypes (:,1) string { mustBeMember(filetypes, [".png", ".pdf", ".eps"]) }

        kwargs.colormap (:,3) double { mustBeInRange( kwargs.colormap, 0, 1 ) } = []

        kwargs.fontsize (1,1) double { mustBePositive } = 20

        kwargs.resolution (1,1) double { mustBePositive } = 400

        kwargs.decplaces (1,1) double { mustBeInteger, mustBeNonnegative } = 1

    end

    % Locate the Zeffiro Figure tool's right colorbar by tag.
    ftcb = findobj(figtool,'Tag','rightColorbar');

    % Create a new figure for the colorbar and register cleanup on interrupt.
    fig = figure ;
    cleanup_fn = @( hh ) close ( hh ) ;
    cleanup_obj = onCleanup ( @() cleanup_fn ( fig ) ) ;

    % Apply colormap: optional override or copy from source figure.
    if not ( isempty ( kwargs.colormap ) )
        fig.Colormap = kwargs.colormap;
    else
        fig.Colormap = figtool.Colormap;
    end

    % Add axes and colorbar; replicate limits and 5 evenly spaced ticks.
    ax = axes ( fig );
    cb = colorbar ( ax ) ;

    lowerlim = ftcb.Limits(1) ;

    upperlim = ftcb.Limits(2) ;

    delta = ( upperlim - lowerlim ) / 5 ;

    cb.Ticks = lowerlim : delta : upperlim ;

    cb.TickLabels = round ( cb.Ticks, kwargs.decplaces ) ;

    cb.FontSize = kwargs.fontsize ;

    % Set color limits. caxis was renamed to clim in R2022b; dispatch by version.
    matlab_release = version( '-release' ) ;

    release = matlab_release ( end - 4 : end ) ;

    year = double ( string ( release ( 1 : 4 ) ) );

    letter = release ( end ) ;

    if year >= 2023

        climits_fn = @clim ;

    elseif year == 2022 && letter == 'b'

        climits_fn = @clim ;

    else

        climits_fn = @caxis ;

    end

    climits_fn(ax, ftcb.Limits);

    % Hide axes so only the colorbar is visible in the export.
    ax.Visible = matlab.lang.OnOffSwitchState.off;

    % Export to each requested format.
    for si = 1 : numel ( filetypes )

        suffix = filetypes ( si ) ;

        exportgraphics(fig, filename_without_suffix + suffix, "Resolution", kwargs.resolution);

    end

end % function
