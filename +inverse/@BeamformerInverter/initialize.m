function self = initialize(self,L,f_data)
%initialize  Estimate Beamformer error_cov from the measurement frames.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called once from utilities.inverse.run_frame_loop before the per-frame
%   invert loop (not from invert itself). Inverse tools → Beamformer uses
%   zef_beamformer and never reaches this method.
%
%   If error_cov is already set, this is a no-op besides
%   computing_parameters = true. Otherwise:
%     several frames — demeaned sample covariance / n_frames
%                      (f-mean(f,2))*(f-mean(f,2))'/T
%     one frame      — outer product of the demeaned vector (mean along
%                      dim 1). invert then Tikhonov-regularizes this C
%                      and uses L_modified = C \ L.
%   L is unused (kept for the common initialize(L, f_data) signature).
%
%   Inputs
%     L      - processed lead field (ignored).
%     f_data - n_sensors × n_frames measurements after filtering
%              (all framed columns, or zef.inverse_initialization_measurements).
%
%   Output
%     self.error_cov  n_sensors × n_sensors, unless it was already set.
%
%   See also inverse.BeamformerInverter/invert, utilities.inverse.run_frame_loop.

    arguments

        self (1,1) inverse.BeamformerInverter

        L (:,:) {mustBeA(L,["double","gpuArray"])}

        f_data (:,:) {mustBeA(f_data,["double","gpuArray"])}

    end
    self.computing_parameters = true;
   % Compute error covariance matrix if it is not given
   if isempty(self.error_cov)
       if size(f_data,2) > 1
           self.error_cov = (f_data-mean(f_data,2))*(f_data-mean(f_data,2))'/size(f_data,2);
       else
           self.error_cov = (f_data-mean(f_data,1))*(f_data-mean(f_data,1))';
       end
   end

end
