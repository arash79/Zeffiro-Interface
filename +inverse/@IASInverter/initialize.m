function self = initialize(self,L,f_data)
%initialize  IAS hyperprior parameters (beta, theta0, d_sqrt) and noise covariance.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called once from utilities.inverse.run_frame_loop before invert.
%   Inverse tools → IAS uses zef_ias_iteration, not this method.
%
%   modified_SNR = signal_to_noise_ratio - prior_over_measurement_db + amplitude_db
%   hyperprior "Inverse gamma" → zef_find_ig_hyperprior, d_sqrt = sqrt(theta0/(beta-1))
%   hyperprior "Gamma"         → zef_find_g_hyperprior,  d_sqrt = sqrt(theta0*beta)
%   theta0/(beta-1) (IG) and theta0*beta (Gamma) are prior *variances*; the
%   MAP filter uses standard deviations, matching zef_ias_iteration.
%   hyperprior_mode "Balanced" sets the spatial-balance flag on those helpers.
%   data_normalization_method is passed through as 'maximum entry' or
%   'something else' (the helpers only special-case the first string).
%   noise_cov is always (10^(-SNR/10))*I (not estimated from f_data).
%   f_data is unused (common initialize signature).
%
%   Inputs
%     L      - processed lead field (column count = source DOF for the helpers).
%     f_data - unused.
%
%   Output
%     self with dynamic props theta0, beta, d_sqrt, noise_cov filled.

    arguments

        self (1,1) inverse.IASInverter

        L (:,:) {mustBeA(L,["double","gpuArray"])}

        f_data (:,:) {mustBeA(f_data,["double","gpuArray"])}

    end

    if not(isprop(self,'theta0'))
        self.addprop('theta0');
    end
    if not(isprop(self,'beta'))
        self.addprop('beta');
    end
    if not(isprop(self,'d_sqrt'))
        self.addprop('d_sqrt');
    end
    if not(isprop(self,'noise_cov'))
        self.addprop('noise_cov');
    end
    
    if strcmp(self.hyperprior_mode,"Balanced")
        balance_spatially = 1;
    else
        balance_spatially = 0;
    end
    
    if strcmp(self.data_normalization_method,"Maximum entry")
        normalize_data = 'maximum entry';
    else
        normalize_data = 'something else';
    end
    
    modified_SNR = self.signal_to_noise_ratio-self.prior_over_measurement_db + self.amplitude_db;
    
    if strcmp(self.hyperprior,"Inverse gamma")
        [self.beta, self.theta0] = zef_find_ig_hyperprior(modified_SNR,...
            self.hyperprior_tail_length_db,L,size(L,2),normalize_data,balance_spatially,self.hyperprior_weight);
        self.d_sqrt = sqrt(self.theta0./(self.beta-1));
    elseif strcmp(self.hyperprior,"Gamma")
        [self.beta, self.theta0] = zef_find_g_hyperprior(modified_SNR,...
            self.hyperprior_tail_length_db,L,size(L,2),normalize_data,balance_spatially,self.hyperprior_weight);
        self.d_sqrt = sqrt(self.theta0.*self.beta);
    end


    noise_p2 = 10^(-self.signal_to_noise_ratio/10);
    self.noise_cov = noise_p2*eye(size(L,1));




end
