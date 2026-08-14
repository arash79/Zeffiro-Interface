function self = initialize(self,L,f_data)
%initialize  HALpR noise_cov (if empty) and SNR_variable for hyperpriors.
%
%   Zeffiro Interface.
%   Copyright © 2025- Joonas Lahtinen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Adds dynamic property SNR_variable if missing. noise_cov: cov(f') when
%   several frames, else (10^(-SNR/10))*mean(f.^2)*I. SNR_variable =
%   (1-noise_p2)*10^(initial_prior_steering_db/10)*data_power with
%   data_power = mean channel variance (multi-frame) or mean(f.^2).
%   Same formulae as GroupLassoInverter.initialize. Called from
%   utilities.inverse.run_frame_loop before invert (not from invert).
%   Inverse tools → Standardized Hierarchical L1 MAP uses zef_sl1_iteration.
%
%   Inputs
%     L      - processed lead field (size(L,1) for the one-frame noise I).
%     f_data - n_sensors × n_frames filtered measurements.
%
%   Output
%     self.noise_cov, self.SNR_variable as in GroupLassoInverter.initialize.

        arguments
    
            self (1,1) inverse.HALpRInverter
    
            L (:,:) {mustBeA(L,["double","gpuArray"])}
    
            f_data (:,:) {mustBeA(f_data,["double","gpuArray"])}
    
        end

        if not(isprop(self,'SNR_variable'))
            self.addprop('SNR_variable');
        end

        noise_p2 = 10^(-self.signal_to_noise_ratio/10);

        if isempty(self.noise_cov)
            if size(f_data,2) > 1
                self.noise_cov = cov(f_data');
            else
                self.noise_cov = noise_p2 * mean(f_data.^2) * eye(size(L,1));
            end
        end
        
        if size(f_data, 2) > 1
            data_power = mean(var(f_data, 0, 2));
        else
            data_power = mean(f_data(:).^2);
        end
        if isa(data_power, "gpuArray")
            data_floor = gpuArray(eps(classUnderlying(data_power)));
        else
            data_floor = eps(class(data_power));
        end
        data_power = max(data_power, data_floor);

        self.SNR_variable = ...
            (1-noise_p2) * 10.^(self.initial_prior_steering_db/10) * data_power;
end
