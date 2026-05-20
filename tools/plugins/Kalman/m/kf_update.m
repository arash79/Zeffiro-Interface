function [m, P, K] = kf_update(m,P,y,H,R)
% --- Zeffiro documentation header ---
% kf_update — Kf update.
%
% Purpose:
%   Kf update.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
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
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[m, P, K]] = kf_update(m, P, y, H, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    v = y - H*m;
    PHt = P * H';
    S = H * PHt + R; 
    S = (S + S')/2;  % Ensure S is symmetric positive definite for numerical stability
    K = PHt / S;
    m = m + K*v;
    P = P - K * PHt'; % we have K = PHt / S then PHt = K*S hence PHt' = S*K' (s is symmetric)
    P = (P + P')/2; % Ensure P is symmetric positive definite for numerical stability
end
