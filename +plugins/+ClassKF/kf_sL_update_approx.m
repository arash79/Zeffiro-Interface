function [m, P, K, D] = kf_sL_update_approx(m, P, y, H, R)
% --- Zeffiro documentation header ---
% plugins.ClassKF.kf_sL_update_approx — Kf s L update approx.
%
% Purpose:
%   Kf s L update approx.
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
%   D
%
% Calls (project):
%   plugins.ClassKF.kf_sL_update_approx
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[m, P, K]] = plugins.ClassKF.kf_sL_update_approx(m, P, y, H, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

N = 5; M_iter = 1;
    Z = eye(length(m));
    Y_mat = P;
    invY = Z;
    invZ = Z;
    for n = 1:N
        for k = 1:M_iter
            invY = 2*invY - invY*Y_mat*invY;
            invZ = 2*invZ - invZ*Z*invZ;
        end
        Y_mat = 0.5*(Y_mat + invZ);
        Z = 0.5*(Z + invY);
    end
    P_sqrtm_right = Z;
    B = H * P;  % H * P^(1/2) approximation
    K = B*P_sqrtm_right;
    G = K' / (B * H' + R);
    w_t = 1 ./ sqrt(sum(G.' .* K, 1))';
    D = w_t .* P_sqrtm_right;

    % Standard Kalman update
    v = y - H*m;
    PHt = P * H';
    S = H * PHt + R;
    S = (S + S')/2; % Ensure S is symmetric positive definite for numerical stability
    K = PHt / S;
    m = m + K*v;
    P = P - K * PHt';
    P = (P + P')/2; % Ensure P is symmetric positive definite for numerical stability



end
