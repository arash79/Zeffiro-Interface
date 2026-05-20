function [m, P] = class_kf_predict(KFclassObj)
%CLASS_KF_PREDICT Prediction step of the Kalman filter (object-oriented interface).
%
%   [M, P] = CLASS_KF_PREDICT(KFclassObj) performs the Kalman filter prediction
%   step using the state transition model and evolution covariance from
%   KFclassObj. Optimizes when the state transition matrix A is identity.
%
%   Input:
%     KFclassObj - Kalman filter object with fields:
%                  state_transition_model_A, prev_step_reconstruction,
%                  prev_step_posterior_cov, evolution_cov
%
%   Outputs:
%     M - Predicted state mean: m_pred = A * m_prev (or m_prev if A = I)
%     P - Predicted state covariance: P_pred = A*P_prev*A' + Q (or P_prev + Q if A = I)

if (isdiag(KFclassObj.state_transition_model_A) && all(diag(KFclassObj.state_transition_model_A) - 1) < eps)
    % Identity transition: m unchanged, P = P + Q
    P = KFclassObj.prev_step_posterior_cov + KFclassObj.evolution_cov;
    m = KFclassObj.prev_step_reconstruction;
else
    % Full Kalman prediction equations
    m = KFclassObj.state_transition_model_A * KFclassObj.prev_step_reconstruction;
    P = KFclassObj.state_transition_model_A * KFclassObj.prev_step_posterior_cov * KFclassObj.state_transition_model_A' + KFclassObj.evolution_cov;
end
end
