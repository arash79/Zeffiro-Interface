function [z_vec, time_series, self] = UKF_estimate_NMM_parameters(self, L)
%UKF_ESTIMATE_NMM_PARAMETERS  Cluster SKF sources and fit Jansen–Rit via UKF.
%
%   Zeffiro Interface.
%   Copyright © 2025- Joonas Lahtinen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Detects sources that support number_of_corrclusters distinct spike
%   activities over the recording. Each cluster's time evolution is
%   modelled with the Jansen–Rit neural mass model; the 11 JR parameters
%   are estimated with an unscented Kalman filter.
%
%   Called from smoother after the spatial Kalman sequence (and optional
%   RTS) is assembled. Not called from invert.
%
%   Algorithm (preserved from commit 0b33ef8c, with runtime guards):
%     1. Source-wise magnitude time series from xyz triplets.
%     2. Drop sources whose peak is not > score_threshold after global
%        max-normalisation.
%     3. Gram matrix Corr_matrix = z*z' (not a normalised correlation
%        matrix; downstream k-means uses this similarity as committed).
%     4. kmeans(Corr_matrix, number_of_corrclusters+1); discard the
%        lowest-score cluster as "nonsense".
%     5. Estimate spike peak times from the mean SKF time course.
%     6. For each cluster, UKF on JR parameters using back-projected
%        spatial potentials L(:,cluster)*x(cluster,:) as observations.
%     7. Reconstruct z_vec(cluster,:) = contribution_vec .* JR_signal.
%
%   [z_vec, time_series, self] = UKF_estimate_NMM_parameters(self, L)
%
%   Inputs
%     L - original lead field (not modified_L).
%
%   Outputs
%     z_vec       - n_dof × T NMM-constrained reconstruction.
%     time_series - n_clusters × T Jansen–Rit signals.
%     self        - value-class copy (noise_cov gathered if it was GPU).

    arguments
        self (1,1) inverse.UKFNMMInverter
        L (:,:)
    end

    if isgpuarray(L)
        L = gather(L);
    end
    if isgpuarray(self.reconstruction)
        self.reconstruction = gather(self.reconstruction);
    end
    if isgpuarray(self.noise_cov)
        self.noise_cov = gather(self.noise_cov);
    end
    L = double(L);
    self.reconstruction = double(self.reconstruction);
    self.noise_cov = double(self.noise_cov);

    if isempty(self.reconstruction)
        error("UKFNMMInverter:EmptyReconstruction", ...
            "Spatial reconstruction is empty; run invert over all frames before NMM/UKF.");
    end
    n_dof = size(self.reconstruction, 1);
    n_time = size(self.reconstruction, 2);
    if n_time ~= self.number_of_frames
        error("UKFNMMInverter:NMMFrameCountMismatch", ...
            "reconstruction has %d time columns but number_of_frames is %d.", ...
            n_time, self.number_of_frames);
    end
    if n_dof ~= size(L, 2)
        error("UKFNMMInverter:NMMLeadFieldMismatch", ...
            "reconstruction has %d rows but L has %d columns.", n_dof, size(L, 2));
    end
    if mod(n_dof, 3) ~= 0
        error("UKFNMMInverter:InvalidSourceDimensionality", ...
            "NMM source indexing requires size(reconstruction,1) divisible by 3; got %d.", n_dof);
    end
    if ~all(isfinite(self.reconstruction(:))) || ~all(isfinite(L(:)))
        error("UKFNMMInverter:NonFiniteNMMInput", ...
            "Reconstruction or lead field contains NaN or Inf.");
    end
    if exist('kmeans', 'file') ~= 2
        error("UKFNMMInverter:MissingKmeans", ...
            "UKFNMM requires the Statistics and Machine Learning Toolbox function kmeans.");
    end

    n_clusters = double(self.number_of_corrclusters);
    z_vec = zeros(size(self.reconstruction));
    time_series = zeros(n_clusters, n_time);

    t_span = 0:(1 / self.sampling_frequency):((self.number_of_frames - 1) / self.sampling_frequency);
    if numel(t_span) < self.number_of_frames
        error("UKFNMMInverter:TimeAxisTooShort", ...
            "Sampling grid has %d points but number_of_frames is %d.", ...
            numel(t_span), self.number_of_frames);
    end
    t_span = t_span(1:self.number_of_frames);

    n = n_dof / 3;
    z = sqrt(reshape(sum(reshape(self.reconstruction.^2, 3, [])), n, []));
    z_max = max(z, [], "all");
    if ~(z_max > 0) || ~isfinite(z_max)
        error("UKFNMMInverter:ZeroReconstruction", ...
            "Spatial reconstruction is all zero; Jansen-Rit NMM has no source activity to fit.");
    end
    z = z / z_max;
    s_ind = find(max(z, [], 2) > self.score_threshold);
    if isempty(s_ind)
        error("UKFNMMInverter:NoSignificantSources", ...
            "No source exceeded score_threshold=%g after max-normalisation.", ...
            self.score_threshold);
    end
    z = z(s_ind, :);
    n_surviving = size(z, 1);
    n_k = n_clusters + 1;
    if n_surviving < n_k
        error("UKFNMMInverter:TooFewSourcesForClusters", ...
            "%d sources survived score_threshold, but kmeans is run with %d clusters (number_of_corrclusters+1=%d). Lower number_of_corrclusters or score_threshold.", ...
            n_surviving, n_k, n_k);
    end

    % Gram / unnormalised similarity, not Pearson correlation. Downstream
    % k-means and cluster scoring use this matrix as committed in 0b33ef8c.
    Corr_matrix = z * z';
    if ~all(isfinite(Corr_matrix(:)))
        error("UKFNMMInverter:NonFiniteSimilarity", ...
            "Source similarity matrix contains NaN or Inf.");
    end

    try
        clusters_ind = kmeans(Corr_matrix, n_k);
    catch ME
        error("UKFNMMInverter:KmeansFailed", ...
            "kmeans failed on the source similarity matrix (%d sources, k=%d): %s", ...
            n_surviving, n_k, ME.message);
    end

    score = zeros(1, n_k);
    for ic = 1:n_k
        members = clusters_ind == ic;
        if any(members)
            score(ic) = mean(sum(Corr_matrix(:, members)));
        else
            score(ic) = -Inf;
        end
    end
    if nnz(isfinite(score) & score > -Inf) < n_clusters
        error("UKFNMMInverter:TooFewNonemptyClusters", ...
            "kmeans produced fewer than %d nonempty clusters.", n_clusters);
    end
    [~, cluster_id] = maxk(score, n_clusters);

    [peaking_times, cluster_order] = estimate_peaks( ...
        z, t_span, n_clusters, clusters_ind, cluster_id);

    if numel(peaking_times) ~= n_clusters || numel(cluster_order) ~= n_clusters
        error("UKFNMMInverter:PeakEstimationSize", ...
            "Peak estimation did not return one peak and cluster index per requested cluster.");
    end
    if any(cluster_order < 1) || any(cluster_order > numel(cluster_id))
        error("UKFNMMInverter:InvalidClusterOrder", ...
            "Peak-to-cluster assignment is out of range.");
    end

    N = 11;
    Q = diag(10.^round(log10([3.25; 100.0; 22.0; 50.0; 135.0; 108.0; 33.75; 33.75; 2.5; 6.0; 0.56] / 10)));
    Wmean = zeros(2 * N + 1, 1);
    Wcov = zeros(2 * N + 1, 1);
    UKF_coef = self.alpha^2 * (N + self.kappa);
    if ~(UKF_coef > 0) || ~isfinite(UKF_coef)
        error("UKFNMMInverter:InvalidUKFScaling", ...
            "UKF scaling alpha^2*(N+kappa) must be positive and finite; got %g (alpha=%g, kappa=%g).", ...
            UKF_coef, self.alpha, self.kappa);
    end
    Wmean(1) = (UKF_coef - N) / UKF_coef;
    Wmean(2:end) = 0.5 / UKF_coef;
    Wcov(1) = (UKF_coef - N) / UKF_coef + 1 - self.alpha^2 + self.beta;
    Wcov(2:end) = 0.5 / UKF_coef;

    warn_state = warning;
    cleanup_warn = onCleanup(@() warning(warn_state));
    warning('off');

    T_jr = 1.2 * self.number_of_frames / self.sampling_frequency;
    sigma_scale = self.alpha * sqrt(N + self.kappa);
    if ~isfinite(sigma_scale) || ~(sigma_scale > 0)
        error("UKFNMMInverter:InvalidSigmaScale", ...
            "UKF sigma-point scale alpha*sqrt(N+kappa) is not positive finite.");
    end

    for k = 1:n_clusters
        cluster_members = s_ind(clusters_ind == cluster_id(cluster_order(k)));
        if isempty(cluster_members)
            error("UKFNMMInverter:EmptyCluster", ...
                "Cluster %d (order index %d) has no surviving sources.", k, cluster_order(k));
        end
        s_ind3D = 3 * cluster_members(:)' - [0; 1; 2];
        s_ind3D = s_ind3D(:);
        m = [3.25; 100.0; 22.0; 50.0; 135.0; 108.0; 33.75; 33.75; 2.5; 6.0; 0.56];
        P = eye(N);
        spatial_potentials = L(:, s_ind3D) * self.reconstruction(s_ind3D, :);
        energy = sum(abs(spatial_potentials), 1);
        energy_peak = max(energy);
        if ~(energy_peak > 0) || ~isfinite(energy_peak)
            error("UKFNMMInverter:ZeroClusterPotential", ...
                "Cluster %d back-projected potential is all zero.", k);
        end
        t0 = find(energy > 0.5 * energy_peak, 1);
        if isempty(t0)
            t0 = 1;
        end
        peaking_time = peaking_times(k);
        contribution_vec = [];

        for t = t0:self.number_of_frames
            y = spatial_potentials(:, t);
            P = i_symmetrize(P);
            sqrtP = i_safe_sqrtm(P);
            X0 = m;
            Xp = m + sigma_scale * sqrtP;
            Xm = m - sigma_scale * sqrtP;
            X = [X0, Xp, Xm];

            X_hat = X;

            m = X_hat * Wmean;
            P = zeros(size(P));
            for j = 1:length(Wcov)
                P = P + Wcov(j) * (X_hat(:, j) - m) * (X_hat(:, j) - m)';
            end
            P = i_symmetrize(P + Q);
            sqrtP = i_safe_sqrtm(P);

            X0 = m;
            Xp = m + sigma_scale * sqrtP;
            Xm = m - sigma_scale * sqrtP;
            X = [X0, Xp, Xm];

            f = JR_model([X; repelem(peaking_time, 1, size(X, 2))], T_jr, self.sampling_frequency);
            f(isnan(f)) = 0;
            t_hi = min(t, size(f, 2));
            t_lo = min(t0, t_hi);
            f = f(:, t_lo:t_hi);
            [Y, contribution_vec] = obs(f, s_ind3D, L, y);

            mu = Y * Wmean;
            S = zeros(size(Y, 1));
            C = zeros(size(X, 1), size(Y, 1));
            for j = 1:length(Wcov)
                S = S + Wcov(j) * (Y(:, j) - mu) * (Y(:, j) - mu)';
                C = C + Wcov(j) * (X(:, j) - m) * (Y(:, j) - mu)';
            end
            S = i_symmetrize(S + self.noise_cov);

            K = C / S;
            if any(~isfinite(K(:)))
                error("UKFNMMInverter:UKFObservationCovariance", ...
                    "Predicted observation covariances did not converge properly (NaN/Inf Kalman gain) at cluster %d, frame %d.", k, t);
            end

            m = m + K * (y - mu);
            P = i_symmetrize(P - K * S * K');
            if any(~isfinite(m(:))) || any(~isfinite(P(:)))
                error("UKFNMMInverter:NonFiniteUKFState", ...
                    "UKF state became non-finite at cluster %d, frame %d.", k, t);
            end
        end

        if isempty(contribution_vec)
            error("UKFNMMInverter:NoUKFUpdates", ...
                "UKF produced no updates for cluster %d (t0=%d, frames=%d).", ...
                k, t0, self.number_of_frames);
        end

        f = JR_model([m; peaking_time], T_jr, self.sampling_frequency);
        f(isnan(f)) = 0;
        if size(f, 2) < self.number_of_frames
            error("UKFNMMInverter:JRSequenceTooShort", ...
                "Jansen-Rit signal has %d samples; need %d frames.", ...
                size(f, 2), self.number_of_frames);
        end
        f = f(1:self.number_of_frames);
        z_vec(s_ind3D, :) = contribution_vec .* f;
        time_series(k, :) = f;
    end

    clear cleanup_warn;
end

function P = i_symmetrize(P)
P = (P + P') / 2;
end

function sqrtP = i_safe_sqrtm(P)
P = i_symmetrize(P);
sqrtP = sqrtm(P);
if ~isreal(sqrtP)
    imag_rel = max(abs(imag(sqrtP)), [], "all") / max(1, max(abs(real(sqrtP)), [], "all"));
    if imag_rel > 1e-8
        error("UKFNMMInverter:NonRealSqrtm", ...
            "sqrtm of a UKF covariance produced a non-real result (relative imaginary part %g).", imag_rel);
    end
    sqrtP = real(sqrtP);
end
if any(~isfinite(sqrtP(:)))
    error("UKFNMMInverter:NonFiniteSqrtm", ...
        "sqrtm of a UKF covariance produced NaN or Inf.");
end
end

function sequence = JR_model(params, T, sampling_frequency)
n_param = size(params, 2);
t_span = 0:(1 / sampling_frequency):T;
sequence = zeros(n_param, numel(t_span));
opts = odeset('RelTol', 1e-6, 'AbsTol', 1e-8);

for k = 1:n_param
    pfun = @(t) (t >= params(end, k) & t < params(end, k) + 0.05) * 220;
    X0 = zeros(6, 1);
    odefun = @(t, x) jr_ode(t, x, params(:, k), pfun);
    try
        [t, X] = ode45(odefun, [0, T], X0, opts);
    catch ME
        error("UKFNMMInverter:JRODEFailed", ...
            "ode45 failed while integrating the Jansen-Rit model: %s", ME.message);
    end
    if isempty(t) || size(X, 1) < 1
        error("UKFNMMInverter:JRODEEmpty", ...
            "ode45 returned an empty Jansen-Rit trajectory.");
    end

    V_net = X(:, 3) - X(:, 5);
    [~, tind_max] = max(V_net);
    peak_t = t(tind_max);

    try
        if tind_max < length(t)
            seq = interp1(t + params(end, k) - peak_t, V_net, t_span);
        else
            seq = interp1(t, V_net, t_span);
        end
    catch ME
        error("UKFNMMInverter:JRInterpolationFailed", ...
            "interp1 failed while resampling the Jansen-Rit trajectory: %s", ME.message);
    end
    if isrow(seq)
        sequence(k, :) = seq;
    else
        sequence(k, :) = seq(:).';
    end
end

    function dx = jr_ode(t, x, params_k, pfun_)
        y0 = x(1); y3 = x(2);
        y1 = x(3); y4 = x(4);
        y2 = x(5); y5 = x(6);

        p = pfun_(t);

        S_y1_minus_y2 = Sigm(params_k, y1 - y2);
        S_C1y0 = Sigm(params_k, params_k(5) * y0);
        S_C3y0 = Sigm(params_k, params_k(7) * y0);

        dy0 = y3;
        dy3 = params_k(1) * params_k(2) * S_y1_minus_y2 - 2 * params_k(2) * y3 - (params_k(2)^2) * y0;

        dy1 = y4;
        dy4 = params_k(1) * params_k(2) * (p + params_k(6) * S_C1y0) - 2 * params_k(2) * y4 - (params_k(2)^2) * y1;

        dy2 = y5;
        dy5 = params_k(3) * params_k(4) * (params_k(8) * S_C3y0) - 2 * params_k(4) * y5 - (params_k(4)^2) * y2;

        dx = [dy0; dy3; dy1; dy4; dy2; dy5];
    end
end

function [Y, contribution_vec] = obs(time_sequence, s_ind3D, L, data)
M = L(:, s_ind3D);
n_interp = numel(s_ind3D) / 3;
if abs(n_interp - round(n_interp)) > 0
    error("UKFNMMInverter:ObservationIndexLength", ...
        "Cluster dipole index list length %d is not divisible by 3.", numel(s_ind3D));
end
n_interp = round(n_interp);
data = data(:);
contribution_vec = zeros(numel(s_ind3D), size(data, 2));
for n = 1:n_interp
    ind = 3 * n - [2, 1, 0];
    contribution_vec(ind, :) = pinv(M(:, ind)) * data;
end
z = reshape(sqrt(sum(reshape(contribution_vec.^2, 3, []))), n_interp, []);
z_max = max(z(:));
if ~(z_max > 0) || ~isfinite(z_max)
    error("UKFNMMInverter:ZeroContributionVector", ...
        "Observation contribution vector has zero or non-finite magnitude.");
end
contribution_vec = contribution_vec ./ z_max;
if size(time_sequence, 2) < 1
    error("UKFNMMInverter:EmptyJRObservation", ...
        "Jansen-Rit sequence passed to the observation model is empty.");
end
Y = (M * contribution_vec) .* transpose(time_sequence(:, end));
if any(~isfinite(Y(:)))
    error("UKFNMMInverter:NonFiniteObservation", ...
        "Error in JR modelled sequence or lead field, e.g. elements with exactly zero value.");
end
end

function s = Sigm(Params, V)
s = (2 * Params(9, :)) ./ (1 + exp(Params(11, :) .* (Params(10, :) - V)));
end

function [peaking_times, cluster_order] = estimate_peaks(reconstruction, t, num_of_clusters, clusters_ind, cluster_id)
dt = mean(diff(t));
if ~(dt > 0) || ~isfinite(dt)
    error("UKFNMMInverter:InvalidSamplingGrid", ...
        "Peak estimation needs a strictly increasing sampling grid.");
end
T0 = size(reconstruction, 2);
if T0 < num_of_clusters
    error("UKFNMMInverter:RecordingTooShortForClusters", ...
        "Peak estimation needs at least %d frames (one per cluster); got %d.", ...
        num_of_clusters, T0);
end

clustered_recs = nan(num_of_clusters + 1, size(reconstruction, 2));
for k = 1:num_of_clusters
    if sum(clusters_ind == cluster_id(k)) > 0
        clustered_recs(k, :) = mean(reconstruction(clusters_ind == cluster_id(k), :), 1);
    end
end
clustered_recs(isnan(clustered_recs(:, 1)), :) = [];
if isempty(clustered_recs)
    error("UKFNMMInverter:NoClusterTimeSeries", ...
        "No nonempty cluster time series were available for peak estimation.");
end

reconstruction = mean(reconstruction, 1);
T = length(reconstruction);

r = rem(T, num_of_clusters);
if r > 0
    [~, ind] = mink(abs(reconstruction), r);
    reconstruction(ind) = [];
    t(ind) = [];
end
T = length(t);
if T < num_of_clusters || rem(T, num_of_clusters) ~= 0
    error("UKFNMMInverter:PeakWindowPartition", ...
        "Could not partition %d samples into %d peak-estimation windows.", T, num_of_clusters);
end
Tsub = T / num_of_clusters;

w_mean = zeros(1, num_of_clusters);
for k = 1:num_of_clusters
    t_end = t(k * Tsub);
    ind_end = k * Tsub;
    w_prev = t(end);
    while (w_mean(k) == 0 || w_mean(k) >= t_end || w_mean(k) <= w_mean(max(k - 1, double(k == 1)))) ...
            && t_end < t(end) && abs(w_prev - w_mean(k)) > dt
        w_prev = w_mean(k);
        ind = ((k - 1) * Tsub + 1):ind_end;
        [~, p_ind] = maxk(reconstruction(ind), min(3, numel(ind)));
        denom = sum(reconstruction(ind(p_ind)));
        if denom == 0 || ~isfinite(denom)
            w_mean(k) = mean(t(ind(p_ind)));
        else
            w_mean(k) = sum(reconstruction(ind(p_ind)) .* t(ind(p_ind))) / denom;
        end
        ind_end = min(max(floor(ind_end + 0.1 * Tsub), ind_end + 1), length(t));
        t_end = t(ind_end);
    end
    if k == num_of_clusters && w_mean(k) == 0
        w_mean(k) = t(end);
    end
end

n_pick = min(3, size(clustered_recs, 1));
peaking_times = zeros(1, num_of_clusters);
cluster_order = zeros(n_pick, num_of_clusters);
cluster_val = cluster_order;
for k = 1:num_of_clusters
    [~, ind] = min(abs(t - w_mean(k)));
    ind = max(ind - 2, 1):min(ind + 2, T);
    [~, ind2] = max(abs(reconstruction(ind)));
    peaking_times(k) = t(ind(ind2));
    [val, idx] = maxk(clustered_recs(:, ind(ind2)), n_pick);
    cluster_order(:, k) = idx;
    cluster_val(:, k) = val;
end

[~, idx, idc] = unique(cluster_order(1, :));
if length(idx) == num_of_clusters
    cluster_order = cluster_order(1, :);
else
    j = 1;
    while length(idx) ~= num_of_clusters && j < size(cluster_order, 1)
        j = j + 1;
        [count, ~, idxc] = histcounts(idc, numel(idx));
        non_unique_order = cluster_order(1, count(idxc) > 1);
        flavor = unique(non_unique_order);
        for n = 1:length(flavor)
            ind = find(cluster_order(1, :) == flavor(n));
            [~, m_ind] = max(cluster_val(1, ind));
            m_ind = setdiff(ind, ind(m_ind));
            cluster_order(1, m_ind) = cluster_order(j, m_ind);
        end
        [~, idx, idc] = unique(cluster_order(1, :));
    end
    cluster_order = cluster_order(1, :);
end
end
