function self = initialize(self,L,f_data)
%initialize  RAMUS noise_cov = 10^(-SNR/10) * I (always overwritten).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Adds dynamic property noise_cov if missing. Unlike dipole scan, this
%   does not scale by mean(f.^2) and does not keep a user-supplied matrix.
%   f_data unused. Multiresolution hyperpriors are built inside invert.
%   Called from utilities.inverse.run_frame_loop before invert.
%   Inverse tools → RAMUS uses zef_ramus_iteration.
%
%   self = initialize(self, L, f_data)

    arguments

        self (1,1) inverse.RAMUSInverter

        L (:,:) {mustBeA(L,["double","gpuArray"])}

        f_data (:,:) {mustBeA(f_data,["double","gpuArray"])}

    end

    if not(isprop(self,'noise_cov'))
        self.addprop('noise_cov');
    end
    
    noise_p2 = 10^(-self.signal_to_noise_ratio/10);
    self.noise_cov = noise_p2*eye(size(L,1));
end
