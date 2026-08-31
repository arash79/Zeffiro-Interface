function self = initialize(self, L, f_data)
%initialize  Set spatial-Kalman priors, Q, and the SVD-modified lead field.
%
%   Zeffiro Interface.
%   Copyright © 2025- Joonas Lahtinen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called once from utilities.inverse.run_frame_loop before invert.
%   Resets filter state so a new run does not reuse the previous mean or
%   covariance. Builds:
%     - noise_cov from SNR (or trace-normalises a user matrix)
%     -     theta0 from early-frame data variance and zef_leadfield_column_energy
%       (interleaved xyz triples)
%     - evolution_cov / evolution_var from evolution_prior_model
%     - modified_L by replacing each source's three lead-field columns
%       with the thin SVD left vectors U
%     - u_to_dipole = V S^{+} so NMM can recover physical dipoles from
%       the U-space Kalman state
%     - identity A when state_transition_model_A is empty
%
%   Requires a 3-component (xyz) source layout: size(L,2) must be
%   divisible by 3, and size(L,1) must be at least 3 so each U is
%   n_sensors-by-3. Fixed-orientation source_direction_mode 3 is rejected.
%
%   Inputs:  L — lead field; f_data — n_sensors × T measurements.
%   Output:  self with priors, modified_L, and transition model.

    arguments
        self (1,1) inverse.UKFNMMInverter
        L (:,:) {mustBeA(L,["double","gpuArray"])}
        f_data (:,:) {mustBeA(f_data,["double","gpuArray"])}
    end

    if isempty(L) || size(L, 1) < 1 || size(L, 2) < 1
        error("UKFNMMInverter:EmptyLeadField", ...
            "Lead field L is empty.");
    end
    if isempty(f_data)
        error("UKFNMMInverter:EmptyMeasurements", ...
            "f_data has no samples.");
    end
    if size(f_data, 1) ~= size(L, 1)
        error("UKFNMMInverter:MeasurementLeadFieldMismatch", ...
            "f_data has %d rows but L has %d sensors.", size(f_data, 1), size(L, 1));
    end
    if ~all(isfinite(double(gather(L(:)))))
        error("UKFNMMInverter:NonFiniteLeadField", ...
            "Lead field L contains NaN or Inf.");
    end
    if ~all(isfinite(double(gather(f_data(:)))))
        error("UKFNMMInverter:NonFiniteMeasurements", ...
            "f_data contains NaN or Inf.");
    end

    i_require_triplet_lead_field(L);

    self.prev_step_reconstruction = [];
    self.prev_step_posterior_cov = [];
    self.reconstruction = [];
    self.time_series = [];
    self.posterior_covs = cell(0);
    self.n_temporal_postprocess_runs = 0;
    self.modified_L = [];
    self.u_to_dipole = [];

    external_Q = [];
    if strcmp(self.evolution_prior_model, "User supplied Q")
        external_Q = self.evolution_cov;
    end
    self.evolution_cov = [];
    if ~isprop(self, 'evolution_var')
        self.addprop('evolution_var');
    end
    self.evolution_var = [];

    noise_p2 = 10^(-self.signal_to_noise_ratio / 10);

    if isempty(self.noise_cov)
        self.noise_cov = noise_p2 * eye(size(L, 1));
    else
        self.noise_cov = size(L, 1) * self.noise_cov / trace(self.noise_cov);
    end

    n_noise = min(double(self.number_of_noise_steps), size(f_data, 2));
    data_var = mean(var(f_data(:, 1:n_noise), 0, 2));
    if ~(data_var > 0) || ~isfinite(data_var)
        data_var = mean(f_data(:, 1).^2);
        if ~(data_var > 0) || ~isfinite(data_var)
            data_var = noise_p2;
        end
    end
    sensitivity = zef_leadfield_column_energy(L, 1);
    if any(~isfinite(sensitivity)) || any(sensitivity <= 0)
        error("UKFNMMInverter:InvalidLeadFieldSensitivity", ...
            "Per-source lead-field energy is zero or non-finite; cannot form theta0.");
    end
    self.theta0 = (1 - noise_p2) * 10.^(self.initial_prior_steering_db / 10) ...
        * data_var ./ sensitivity;

    n_frames = size(f_data, 2);
    needs_temporal_diff = ismember(self.evolution_prior_model, ...
        ["Sensitivity scaling", "Avg. sensit. scaling", "SVD-based", "Avg. SVD-based"]);
    if needs_temporal_diff && n_frames < 2
        error("UKFNMMInverter:InsufficientFramesForProcessNoise", ...
            "evolution_prior_model '%s' needs at least 2 measurement frames to form Q; got %d. Use ""Reworked original"" or ""User supplied Q"" for a single frame.", ...
            self.evolution_prior_model, n_frames);
    end

    switch self.evolution_prior_model
        case "User supplied Q"
            if isempty(external_Q)
                error("UKFNMMInverter:MissingUserQ", ...
                    "evolution_prior_model is ""User supplied Q"" but evolution_cov is empty. " + ...
                    "Pass Q in MethodParams as field ""evolution_cov"".");
            end
            if isa(external_Q, "gpuArray")
                external_Q = gather(external_Q);
            end
            external_Q = double(external_Q);
            n_state = size(L, 2);
            if ~isequal(size(external_Q), [n_state, n_state])
                error("UKFNMMInverter:BadUserQSize", ...
                    "Q (evolution_cov) must be %d-by-%d to match the lead-field column count; got %s.", ...
                    n_state, n_state, mat2str(size(external_Q)));
            end
            self.evolution_cov = external_Q;
        case "Sensitivity scaling"
            f = sqrt(mean(diff(f_data').^2, 2)) * 10^(self.evolution_prior_db / 20);
            f = [f; f(end)];
            self.evolution_var = transpose((1 - noise_p2) * f ./ sensitivity);
        case "Avg. sensit. scaling"
            f = sqrt(mean(diff(f_data').^2, 2)) * 10^(self.evolution_prior_db / 20);
            f = [f; f(end)];
            self.evolution_var = transpose((1 - noise_p2) * f / mean(sensitivity));
        case "SVD-based"
            [~, S, V] = svd(L, "econ");
            f = diff(f_data')';
            f = 10^(self.evolution_prior_db / 20) * sum(f.^2, 2) ./ sum(f_data.^2, 2);
            S = max((diag(S).^2), noise_p2 / (1 - noise_p2));
            self.evolution_cov = (V .* (f ./ S)') * V';
        case "Avg. SVD-based"
            S = svd(L);
            f = diff(f_data')';
            f = sum(f.^2, 2) ./ sum(f_data.^2, 2);
            S = max(S.^2, noise_p2 / (1 - noise_p2));
            self.evolution_cov = (mean(f ./ S) * 10^(self.evolution_prior_db / 20)) * speye(size(L, 2));
        case "Reworked original"
            self.evolution_cov = self.time_step * (svds(L, 1).^(2) / sum(L(:).^2)) ...
                * 10^(self.evolution_prior_db / 20) * speye(size(L, 2));
    end

    if isempty(self.state_transition_model_A)
        self.state_transition_model_A = speye(size(L, 2));
    else
        if ~isequal(size(self.state_transition_model_A), [size(L, 2), size(L, 2)])
            error("UKFNMMInverter:BadTransitionSize", ...
                "state_transition_model_A must be %d-by-%d; got %s.", ...
                size(L, 2), size(L, 2), mat2str(size(self.state_transition_model_A)));
        end
    end

    [self.modified_L, self.u_to_dipole] = i_build_modified_lead_field(L);
end

function i_require_triplet_lead_field(L)
n_sensors = size(L, 1);
n_dof = size(L, 2);
if mod(n_dof, 3) ~= 0
    error("UKFNMMInverter:InvalidSourceDimensionality", ...
        "UKFNMM requires a 3-component (xyz) source layout so size(L,2) is divisible by 3; got size(L)=[%d, %d]. Fixed-orientation source_direction_mode 3 is not supported.", ...
        n_sensors, n_dof);
end
if n_sensors < 3
    error("UKFNMMInverter:InsufficientSensors", ...
        "Per-source SVD replacement of three lead-field columns requires at least 3 sensors; got %d.", ...
        n_sensors);
end
end

function [modified_L, u_to_dipole] = i_build_modified_lead_field(L)
%I_BUILD_MODIFIED_LEAD_FIELD  Replace each xyz triplet with thin SVD U.
%
%   For source n, L_n = L(:, 3n-2:3n) is n_sensors-by-3. svd(..., "econ")
%   returns U of size n_sensors-by-3 when n_sensors >= 3, which replaces
%   those columns as the Kalman observation model (y = U x_U). Physical
%   dipoles satisfy L_n p = U S V' p, so x_U = S V' p and
%   p = V S^{+} x_U (tiny singular values dropped).
n_sources = size(L, 2) / 3;
modified_L = L;
u_to_dipole = zeros(3, 3, n_sources);
for n = 1:n_sources
    s_ind = 3 * n - [2, 1, 0];
    [u, S, V] = svd(L(:, s_ind), "econ");
    if size(u, 2) ~= 3 || size(u, 1) ~= size(L, 1)
        error("UKFNMMInverter:ModifiedLeadFieldShape", ...
            "SVD of source %d produced U of size %s; expected %d-by-3.", ...
            n, mat2str(size(u)), size(L, 1));
    end
    modified_L(:, s_ind) = u;
    s = diag(S);
    smax = max(s);
    tol = max(smax, eps) * eps * numel(s);
    sinv = zeros(size(s));
    keep = s > tol;
    sinv(keep) = 1 ./ s(keep);
    u_to_dipole(:, :, n) = V * diag(sinv);
end
end
