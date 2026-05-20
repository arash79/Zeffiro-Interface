function [m, P] = class_kf_predict(KFclassObj)
% --- Zeffiro documentation header ---
% plugins.ClassKF.class_kf_predict — Class kf predict.
%
% Purpose:
%   Class kf predict.
%   Folder: Namespaced algorithm support (e.g. ClassGMM, ClassKF) used by GUI plugins and class inverters.
%
% Inputs:
%   KFclassObj
%
% Outputs:
%   m
%   P
%
% Calls (project):
%   plugins.ClassKF.class_kf_predict
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[m, P]] = plugins.ClassKF.class_kf_predict(KFclassObj)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
