function self = initialize(self, L, f_data)
%initialize  Estimate eLORETA noise covariance and regularization from data.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called once from utilities.inverse.run_frame_loop before precompute /
%   invert. There is no default-profile Inverse-tools button for this class.
%   If noise_cov is empty, uses sample covariance of f_data when multiple frames
%   exist, otherwise SNR-scaled identity. If regularization_parameter (alpha) is
%   empty, sets alpha = trace(L*L') / (n_sensors * 10^(SNR/10)).
%
%   Inputs:  self — ELORETAInverter; L — lead field; f_data — m×T measurements.
%   Output:  self with noise_cov and regularization_parameter filled when empty.

arguments
    self (1,1) inverse.ELORETAInverter
    L (:,:) {mustBeA(L,["double","gpuArray"])}
    f_data (:,:) {mustBeA(f_data,["double","gpuArray"])}
end

self.computing_parameters = true;

noise_p2 = 10^(-self.signal_to_noise_ratio/10);

if isempty(self.noise_cov)
    if size(f_data,2) > 1
        self.noise_cov = cov(f_data');
    else
        self.noise_cov = noise_p2 * mean(f_data.^2) * eye(size(L,1), "like", L);
    end
end

if isempty(self.regularization_parameter)
    % α = tr(L L') / (n_sensors * 10^(SNR/10))  when the user did not pin alpha
    self.regularization_parameter = ...
        trace(L*L') / (size(L,1) * 10^(self.signal_to_noise_ratio/10));
end

self.computing_parameters = false;

end
