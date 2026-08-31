function [q] = find_evolution_prior(L, theta0, number_of_frames, evolution_prior_db, prior_over_measurement_db, snr)
%FIND_EVOLUTION_PRIOR  Scalar process-noise scale q from inv_evolution_prior (dB).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   q = find_evolution_prior(L, theta0, number_of_frames, evolution_prior_db, prior_over_measurement_db, snr)
%
%   Called from zef_KF when q_value is omitted:
%   q = (1/n_frames)*10^(2*evolution_prior_db/20)*theta0.
%   L, snr, and prior_over_measurement_db are unused in the formula.
%
%   See also zef_KF.
%

q = (1./number_of_frames)*10^(2*(evolution_prior_db)/20) * theta0;

end
