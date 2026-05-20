%% Copyright © 2025- Joonas Lahtinen
function self = initialize(self,L,f_data)
% --- Zeffiro documentation header ---
% inverse.HALpRInverter.initialize — Estimates priors, noise covariance, or regularization from multi-frame data.
%
% Purpose:
%   Estimates priors, noise covariance, or regularization from multi-frame data.
%   Folder: Object-oriented inverse solvers (`inverse.*Inverter`) sharing `inverse.CommonInverseParameters`; orchestrated from `src/inverse` and `+utilities/+cluster`.
%
% Inputs:
%   self
%   L
%   f_data
%
% Outputs:
%   self
%
% Calls (project):
%   inverse.initialize
%
% Side effects:
%   - GPU
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[self] = inverse.HALpRInverter.initialize(self, L, f_data)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
