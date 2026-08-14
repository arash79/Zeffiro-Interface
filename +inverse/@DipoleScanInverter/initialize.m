function self = initialize(self,L,f_data)
%initialize  Dipole-scan noise_cov = (10^(-SNR/10))*mean(f.^2)*I if empty.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called once from utilities.inverse.run_frame_loop before precompute /
%   invert. Inverse tools → Dipole Scan uses zef_dipoleScan.
%
%   size(L,1) is the sensor count. An existing noise_cov is left unchanged
%   so MethodParams can pin a covariance. precompute then builds
%   whitening = sqrtm(noise_cov) \ I.
%
%   Inputs
%     L      - processed lead field (only size(L,1) is used).
%     f_data - n_sensors × n_frames filtered measurements.
%
%   Output
%     self.noise_cov  n_sensors × n_sensors when it was empty.

    arguments

        self (1,1) inverse.DipoleScanInverter

        L (:,:) {mustBeA(L,["double","gpuArray"])}

        f_data (:,:) {mustBeA(f_data,["double","gpuArray"])}

    end
   if isempty(self.noise_cov)
       noise_p2 = 10^(-self.signal_to_noise_ratio/10);
       self.noise_cov = noise_p2*mean(f_data(:).^2)*eye(size(L,1));
   end

end
