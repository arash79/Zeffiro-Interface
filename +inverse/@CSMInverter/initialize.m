function self = initialize(self,L,f_data)
%initialize  Set CSM prior scale theta0 from SNR and lead-field / data power.
%
%   Zeffiro Interface.
%   Copyright © 2025- Joonas Lahtinen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called once from utilities.inverse.run_frame_loop before precompute /
%   invert. Inverse tools → Classical Sparse Methods uses zef_CSM_iteration.
%
%   noise_p2 = 10^(-SNR/10)
%   theta0   = (1-noise_p2) * ||f_data||_F^2 / ||L||_F^2
%   invert and precompute then use S = (10^(-SNR/20)^2 / theta0) I.
%   Does not set noise_cov.
%
%   Inputs
%     L      - n_sensors × n_dof processed lead field (Frobenius in the ratio).
%     f_data - n_sensors × n_frames filtered measurements.
%
%   Output
%     self.theta0  scalar (gathered from gpuArray if needed).

    arguments

        self (1,1) inverse.CSMInverter

        L (:,:) {mustBeA(L,["double","gpuArray"])}

        f_data (:,:) {mustBeA(f_data,["double","gpuArray"])}

    end

    noise_p2 = 10^(-self.signal_to_noise_ratio/10);
    self.theta0 = gather((1-noise_p2)*sum(f_data.^2,'all')/sum(L.^2,'all'));
end
