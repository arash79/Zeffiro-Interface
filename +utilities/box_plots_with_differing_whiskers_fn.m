function [fig, ax] = box_plots_with_differing_whiskers_fn( ...
    data_cells, ...
    outlier_limits, ...
    x_tick_labels, ...
    x_label, ...
    y_label ...
)

    %
    % BOX_PLOTS_WITH_DIFFERING_WHISKERS_FN Create box plots with custom whisker lengths.
    %
    % [FIG, AX] = box_plots_with_differing_whiskers_fn(DATA_CELLS, OUTLIER_LIMITS,
    %   X_TICK_LABELS, X_LABEL, Y_LABEL) builds a figure containing one box plot
    % per cell in DATA_CELLS, each with a whisker multiplier chosen so that the
    % upper whisker ends at the corresponding value in OUTLIER_LIMITS.
    %
    % Whisker definition (MATLAB boxplot): points are drawn as outliers if they
    % lie outside [q1 - w*(q3-q1), q3 + w*(q3-q1)], where w is the Whisker
    % multiplier and q1, q3 are the 25th and 75th percentiles.
    %

    arguments

        data_cells (:,1) cell

        outlier_limits (:,1) double

        x_tick_labels (:,1) string

        x_label (1,1) string

        y_label (1,1) string

    end % arguments

    assert ( numel( data_cells ) == numel ( outlier_limits ), "There need to be as many data cells as there are outlier limits" );

    assert ( numel( data_cells ) == numel ( x_tick_labels ), "There need to be as many data cells as there are x-tick labels." );

    % Create figure and axes; set axis labels (LaTeX interpreter).
    fig = figure();
    ax = axes(fig);
    xlabel(x_label, "Interpreter", "latex");
    ylabel(y_label, "Interpreter", "latex");

    % Draw all box plots on the same axes with position-based layout.
    hold( ax, "on" )
    index_range = 1 : numel(data_cells);

    for ii = index_range

        % Whisker multiplier w such that upper whisker end = q75 + w*(q75-q25)
        % equals OUTLIER_LIMITS(ii). Solve: w = (ol - q75) / (q75 - q25).
        q25 = quantile(data_cells{ii}, 0.25) ;
        q75 = quantile(data_cells{ii}, 0.75) ;
        ol = outlier_limits(ii) ;
        upper_whisker = ( ol - q75 )  / ( q75 - q25 ) ;

        computation_worked = abs ( ol - ( q75 + upper_whisker * (q75 - q25) ) ) <= eps( ol ) ;
        assert ( computation_worked, "The upper whisker limit must be greater than the 75 % quantile of data series " + ii + "." ) ;

        % Add this group's box plot at position ii with computed whisker length.
        bp = boxplot( ...
            ax, ...
            data_cells{ii}, ...
            "Positions", ii, ...
            "Whisker", upper_whisker ...
        ) ;

    end % for

    xticks(ax, index_range) ;
    xticklabels(ax, x_tick_labels) ;
    grid(ax, "on") ;
    hold( ax, "off" ) ;

end % function
