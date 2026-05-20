function [m, P, K] = kf_update(m, P, y, H, R)
% --- Zeffiro documentation header ---
% plugins.ClassKF.kf_update — Kf update.
%
% Purpose:
%   Kf update.
%   Folder: Namespaced algorithm support (e.g. ClassGMM, ClassKF) used by GUI plugins and class inverters.
%
% Inputs:
%   m
%   P
%   y
%   H
%   R
%
% Outputs:
%   m
%   P
%   K
%
% Calls (project):
%   plugins.ClassKF.kf_update
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[m, P, K]] = plugins.ClassKF.kf_update(m, P, y, H, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

v = y - H*m;
PHt = P * H';
S = H * PHt + R;
S = (S + S')/2;  % Ensure S is symmetric positive definite for numerical stability
K = PHt / S;
m = m + K*v;
P = P - K * PHt';
P = (P + P')/2; % Ensure P remains symmetric positive definite
end
