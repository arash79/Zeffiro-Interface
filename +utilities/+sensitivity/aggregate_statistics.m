function stats = aggregate_statistics(runs)
%AGGREGATE_STATISTICS  Mean and std of Monte Carlo sensitivity metric vectors.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   stats = aggregate_statistics(runs)
%
%   runs is a cell of per-realization metric structs (dist_vec, angle_vec,
%   mag_vec, dispersion_vec). Returns per-run cells plus *_avg and *_std
%   column vectors. std columns are NaN when n_runs == 1.

arguments
    runs (1,:) cell
end

n_runs = numel(runs);
if n_runs == 0
    error("utilities.sensitivity:aggregate_statistics:NoRuns", ...
        "runs must contain at least one realisation.");
end

field_names = ["dist_vec", "angle_vec", "mag_vec", "dispersion_vec"];

stats = struct;
for f = 1:numel(field_names)
    fname = char(field_names(f));
    stats.(fname) = cell(1, n_runs);
end

% Discover the per-realisation vector length from the first non-empty run.
n_rec = i_resolve_n_rec(runs, field_names);

for r = 1:n_runs
    if isempty(runs{r}) || ~isstruct(runs{r})
        for f = 1:numel(field_names)
            stats.(char(field_names(f))){r} = nan(n_rec, 1);
        end
        continue
    end
    for f = 1:numel(field_names)
        fname = char(field_names(f));
        if isfield(runs{r}, fname) && ~isempty(runs{r}.(fname))
            stats.(fname){r} = runs{r}.(fname);
        else
            stats.(fname){r} = nan(n_rec, 1);
        end
    end
end

% Stack each per-realisation column vector into a (n_rec x n_runs) matrix.
dist_mat       = cat(2, stats.dist_vec{:});
angle_mat      = cat(2, stats.angle_vec{:});
mag_mat        = cat(2, stats.mag_vec{:});
dispersion_mat = cat(2, stats.dispersion_vec{:});

stats.dist_vec_avg   = mean(dist_mat,       2, "omitnan");
stats.angle_vec_avg  = mean(angle_mat,      2, "omitnan");
stats.mag_vec_avg    = mean(mag_mat,        2, "omitnan");
stats.dispersion_avg = mean(dispersion_mat, 2, "omitnan");

if n_runs == 1
    % std() of a single sample is undefined; surface NaN columns instead of
    % silently writing zeros so downstream summaries flag the missing data.
    stats.dist_vec_std   = nan(n_rec, 1);
    stats.angle_vec_std  = nan(n_rec, 1);
    stats.mag_vec_std    = nan(n_rec, 1);
    stats.dispersion_std = nan(n_rec, 1);
else
    stats.dist_vec_std   = std(dist_mat,       0, 2, "omitnan");
    stats.angle_vec_std  = std(angle_mat,      0, 2, "omitnan");
    stats.mag_vec_std    = std(mag_mat,        0, 2, "omitnan");
    stats.dispersion_std = std(dispersion_mat, 0, 2, "omitnan");
end

stats.n_runs = n_runs;

end

function n_rec = i_resolve_n_rec(runs, field_names)
%I_RESOLVE_N_REC Inspect the first usable cell to get the metric length.

n_rec = 0;
for r = 1:numel(runs)
    if isempty(runs{r}) || ~isstruct(runs{r})
        continue
    end
    for f = 1:numel(field_names)
        fname = char(field_names(f));
        if isfield(runs{r}, fname) && ~isempty(runs{r}.(fname))
            n_rec = numel(runs{r}.(fname));
            return
        end
    end
end

if n_rec == 0
    error("utilities.sensitivity:aggregate_statistics:AllRunsEmpty", ...
        "All Monte-Carlo realisations are empty; no metrics to aggregate.");
end

end
