function [mag_fig, rdm_fig] = eccentricity_diff_fig_fn( ...
    source_points, ...
    mags, ...
    rdms, ...
    legend_labels, ...
    n_intervals, ...
    x_scale, ...
    min_ecc, ...
    mag_handle_num, ...
    rdm_handle_num ...
    )
%ECCENTRICITY_DIFF_FIG_FN  Boxcharts of log10 MAG/RDM vs radial eccentricity.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [mag_fig, rdm_fig] = eccentricity_diff_fig_fn(source_points, mags, rdms, legend_labels)
%   [mag_fig, rdm_fig] = eccentricity_diff_fig_fn(..., n_intervals, x_scale, min_ecc, mag_h, rdm_h)
%
%   Cell vectors of equal length: source_points{i} must have row count
%   divisible by 3; mags/rdms are column vectors from mag_fn/rdm_fn.
%   Bins ||source||/max into n_intervals (default 5) from min_ecc (0).
%   Figures 101 (MAG) and 100 (RDM); mag_handle_num/rdm_handle_num args
%   are accepted but the bodies always use 101/100. Lab plot helper.
%
%   See also mag_fn, rdm_fn, comparison_all_eccentricities.

arguments

    source_points cell { mustBeVector }

    mags cell { mustBeVector }

    rdms cell { mustBeVector }

    legend_labels cell { mustBeText, mustBeVector }

    n_intervals (1,1) double { mustBeInteger, mustBePositive } = 5;

    x_scale (1,1) double = 1.2;

    min_ecc (1,1) double { ...
        mustBeGreaterThanOrEqual(min_ecc, 0), ...
        mustBeLessThan(min_ecc, 1) ...
        } = 0;

    mag_handle_num double { mustBeInteger, mustBePositive } = 100;

    rdm_handle_num double { mustBeInteger, mustBePositive } = 101;
end

% Close figures if they already exist.

if ishandle(mag_handle_num)
    close(mag_handle_num);
end

if ishandle(rdm_handle_num)
    close(rdm_handle_num);
end

% Set return values.

rdm_fig = figure(100); set(rdm_fig, 'renderer','painters', 'position', [20,20,1000,750]);

rdm_ax = axes(rdm_fig);

mag_fig = figure(101); set(mag_fig, 'renderer','painters', 'position', [20,20,1000,750]);

mag_ax = axes(mag_fig);

% Then start filling the figures in.

source_points_len = numel(source_points);

% Iterate over the source matrices in source_points and generate index
% vectors.

ind_vec_cell = cell(source_points_len,1);

for spi = 1 : source_points_len

    source_point_group = source_points{spi};

    group_size = size(source_point_group);

    if mod(group_size(1), 3) ~= 0

        close(rdm_fig);

        close(mag_fig);

        error("The number of rows in source point matrix was not divisible by 3.");

    end

    n_s_p = sqrt(sum(source_point_group.^2,1));
    n_s_p = repmat(n_s_p,3,1);
    n_s_p = n_s_p(:);
    n_s_p = n_s_p/max(n_s_p);

    % Populate index vector.

    index_vec = zeros(size(n_s_p));

    % Lay out tick labels.

    for ind = 1 : n_intervals

        I = find(n_s_p >= min_ecc + (ind-1)*(1-min_ecc)/n_intervals & n_s_p <= min_ecc + ind*(1-min_ecc)/n_intervals);

        index_vec(I) = ind;

        tick_labels{ind} = round(min_ecc + 0.5*(ind+(ind-1))*(1-min_ecc)/n_intervals,3);

    end % for

    ind_vec_cell{spi} = index_vec;

end % for

% Set tick label positions.

tick_labels = cell(n_intervals,1);

for ind = 1 : n_intervals

    tick_labels{ind} = round(min_ecc + 0.5*(ind+(ind-1))*(1-min_ecc)/n_intervals,3);

end % for

% Group indices stored in index vectors.

flattened_ind_vecs = vertcat(ind_vec_cell{:});

n_of_inds = numel(flattened_ind_vecs);

group_vec = zeros(n_of_inds, 1);

low = 1;

for ind = 1 : source_points_len

    n_cols = 3 * size(source_points{ind},2);

    high = low + n_cols - 1;

    group_vec(low:high) = ind * ones(size(ind_vec_cell{ind}));

    low = high + 1;

end

cat_group_vec = categorical(group_vec);

% Add graphics to plots.

rdm_vec = vertcat(rdms{:});

h_rdm = boxchart( ...
    rdm_ax, ...
    x_scale * flattened_ind_vecs, ...
    log10(rdm_vec), ...
    'GroupByColor', cat_group_vec ...
    );

markersize = 15;

for i = 1 : length(h_rdm)
    set(h_rdm(i),'MarkerStyle','.')
    set(h_rdm(i),'MarkerSize',markersize)
    set(h_rdm(i),'JitterOutliers','off')
    set(h_rdm(i),'linewidth',0.25)
end

set_axis_props_helper(rdm_ax, legend_labels, x_scale, 'Eccentricity', '${\rm RDM}$', n_intervals, tick_labels);

mag_vec = vertcat(mags{:});

h_mag = boxchart( ...
    mag_ax, ...
    x_scale * flattened_ind_vecs, ...
    log10(abs(mag_vec)), ...
    'GroupByColor',group_vec ...
    );

for i = 1 : length(h_mag)
    set(h_mag(i),'MarkerStyle','.')
    set(h_mag(i),'MarkerSize',markersize)
    set(h_mag(i),'JitterOutliers','off')
    set(h_mag(i),'linewidth',0.25)
end

set_axis_props_helper(mag_ax, legend_labels, x_scale, 'Eccentricity', '$\left|{\rm MAG}\right|$', n_intervals, tick_labels);

end % function

%% Helper functions.

function set_axis_props_helper(ax, legend_labels, x_scale, x_label, y_label, n_intervals, tick_labels)

% set_axis_props_helper
%
% Sets axis properties for a given axes ax.

arguments

    ax matlab.graphics.axis.Axes

    legend_labels

    x_scale (1,1) double { mustBePositive }

    x_label (1,1) string

    y_label (1,1) string

    n_intervals (1,1) double { mustBeInteger, mustBePositive }

    tick_labels

end

set(ax,'Xtick',x_scale*[1:n_intervals])
set(ax,'XtickLabels',tick_labels)
set(ax,'xlim',[x_scale/2 x_scale*(n_intervals+1/2)])

pbaspect(ax, [3 1 1])

set(ax,'fontsize',14)
set(ax,'linewidth',0.25)
set(ax,'xgrid','on')
set(ax,'ygrid','on')
set(ax,'box','on')
set(ax,'ylim',[-3 0.5])
set(ax,'ytick',log10([0.00001 0.00002 0.00004 0.00006 0.00008 0.0001 0.0002 0.0004 0.0006 0.0008 0.001 0.002 0.004 0.006 0.008 0.01 0.02 0.04 0.06 0.08 0.1 0.2 0.4 0.6 0.8 1 2 4 6 8 10]))
set(ax,'yticklabels',{'1E-5','2E-5','4E-5','6E-5','8E-5','1E-4','2E-4','4E-4','6E-4','8E-4','1E-3','2E-3','4E-3','6E-3','8E-3','1E-2','2E-2','4E-2','6E-2','8E-2','1E-1','2E-1','4E-1','6E-1','8E-1','1','2','4','6','8','10'})
set(ax,'ticklength',[0.0100 0.0250]/2)

ax.Position = [0.06 0 0.9 0.9];

xlabel(ax, x_label, 'FontSize', 16);
ylabel(ax, y_label , 'Interpreter', 'latex', 'FontSize', 16);

legend(ax, legend_labels,'Orientation','Horizontal','Location','Northwest', 'FontSize', 18)

end
