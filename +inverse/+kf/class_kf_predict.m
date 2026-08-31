function [m, P] = class_kf_predict(KFclassObj)
%CLASS_KF_PREDICT  Kalman predict: m = A x, P = A P A' + Q.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [m, P] = class_kf_predict(KFclassObj)
%
%   Reads KFclassObj.state_transition_model_A, prev_step_reconstruction,
%   prev_step_posterior_cov, and evolution_cov (Q). If A is numerically the
%   identity, skips the multiplies: m unchanged, P = P + Q.
%
%   Called from inverse.KalmanInverter.invert for Basic / standardized /
%   approximated standardized filters, and from inverse.UKFNMMInverter.invert
%   for the spatial stage. EnKF predicts inline instead.
%
%   See also inverse.kf.kf_update, inverse.KalmanInverter,
%            inverse.UKFNMMInverter.

if inverse.kf.is_identity_transition(KFclassObj.state_transition_model_A)
    % Identity transition: m unchanged, P = P + Q
    P = KFclassObj.prev_step_posterior_cov + KFclassObj.evolution_cov;
    m = KFclassObj.prev_step_reconstruction;
else
    % Full Kalman prediction equations
    m = KFclassObj.state_transition_model_A * KFclassObj.prev_step_reconstruction;
    P = KFclassObj.state_transition_model_A * KFclassObj.prev_step_posterior_cov * KFclassObj.state_transition_model_A' + KFclassObj.evolution_cov;
end
end
