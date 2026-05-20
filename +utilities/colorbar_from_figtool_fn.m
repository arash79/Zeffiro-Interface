function colorbar_from_figtool_fn(figtool, filename_without_suffix, filetypes, kwargs)
%COLORBAR_FROM_FIGTOOL_FN Export colorbar from Zeffiro Figure tool to image files.
%
% colorbar_from_figtool_fn(FIGTOOL, FILENAME_WITHOUT_SUFFIX, FILETYPES, kwargs)
% extracts the colorbar from a Zeffiro Interface Figure tool (e.g. loaded from
% a .fig file), creates a standalone figure containing only that colorbar, and
% exports it to the requested file formats (.png, .pdf, .eps).
%
% Inputs:
%   figtool                 - (1,1) matlab.ui.Figure
%                             Handle to the Zeffiro Interface Figure tool.
%   filename_without_suffix - (1,1) string, mustBeValidVariableName
%                             Base filename for output (no extension).
%   filetypes               - (:,1) string, mustBeMember([".png", ".pdf", ".eps"])
%                             Extensions to export (e.g. [".png"; ".pdf"]).
%   kwargs.colormap         - (:,3) double, [0,1], default []
%                             Colormap for the exported colorbar; if empty,
%                             the figure tool's colormap is used.
%   kwargs.fontsize         - (1,1) double, mustBePositive, default 20
%                             Font size (points) for colorbar tick labels.
%   kwargs.resolution       - (1,1) double, mustBePositive, default 400
%                             Resolution (DPI) for raster exports (e.g. PNG).
%   kwargs.decplaces        - (1,1) double, integer >= 0, default 1
%                             Number of decimal places in colorbar tick labels.
%
% Outputs:
%   None. Files are written to the current directory (or path in filename).
%

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
