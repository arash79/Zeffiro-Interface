function stats = aggregate_statistics(runs)
%AGGREGATE_STATISTICS Mean / std across Monte-Carlo realisations.
%
%   stats = aggregate_statistics(runs)
%
% Vectorised replacement for the local add_statistics_to_struct helper in
% +examples/+studies/+santtus_peeling_article/main.m. Two for-loops over
% n_reconstructions become two cat + mean/std calls. The output struct
% keeps the field names downstream code already expects:
%
%   dist_vec / angle_vec / mag_vec / dispersion_vec - 1 x n_runs cell of
%       per-realisation metric vectors (preserved verbatim from `runs`).
%   dist_vec_avg / angle_vec_avg / mag_vec_avg / dispersion_avg - column
%       vectors of length n_rec (3 * n_sources for modes 1/2, n_sources for
%       mode 3), mean over realisations. NaN entries from failed/empty
%       probes are skipped via "omitnan" so a single bad probe does not
%       poison the average.
%   dist_vec_std / angle_vec_std / mag_vec_std / dispersion_std - column
%       vectors of the same shape, std with the legacy (n - 1) divisor.
%       For n_runs == 1 these are returned as NaN columns (std of a single
%       sample is undefined and the legacy code happened to do the same
%       through a divide-by-zero).
%
% Inputs:
%   runs   1 x n_runs cell of structs, each with the fields
%          dist_vec / angle_vec / mag_vec / dispersion_vec produced by
%          utilities.sensitivity.compute_metrics. Empty cells are tolerated
%          (treated as a realisation of NaN entries) so that a partial
%          Monte-Carlo run still produces a meaningful summary.

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
