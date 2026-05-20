% --- Zeffiro documentation header ---
% utilities.plotting.function [fig, ax] = box_plots_with_differing_whiskers_fn( ... — Function [fig, ax] = box plots with differing whiskers fn( .
%
% Purpose:
%   Function [fig, ax] = box plots with differing whiskers fn( ....
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   data_cells
%   outlier_limits
%   x_tick_labels
%   x_label
%   y_label
%
% Calls (project):
%   utilities.plotting.box_plots_with_differing_whiskers_fn
%
% Side effects:
%   - creates/updates figures
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `utilities.plotting.function [fig, ax] = box_plots_with_differing_whiskers_fn( ...(data_cells, outlier_limits, x_tick_labels, x_label, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header
function [fig, ax] = box_plots_with_differing_whiskers_fn( ...
    data_cells, ...
    outlier_limits, ...
    x_tick_labels, ...
    x_label, ...
    y_label ...
)

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
