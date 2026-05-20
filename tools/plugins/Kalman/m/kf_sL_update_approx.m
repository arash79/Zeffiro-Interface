function [m, P, K, D] = kf_sL_update_approx(m,P,y,H,R,standardization_exponent)
% --- Zeffiro documentation header ---
% kf_sL_update_approx — Kf s L update approx.
%
% Purpose:
%   Kf s L update approx.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   m
%   P
%   y
%   H
%   R
%   standardization_exponent
%
% Outputs:
%   m
%   P
%   K
%   D
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[m, P, K]] = kf_sL_update_approx(m, P, y, H, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    N = 5; M = 1;
    Z = eye(length(m));
    Y = P;
    invY = Z;
    invZ = Z;
    for n = 1:N
        for k = 1:M
            invY = 2*invY-invY*Y*invY;
            invZ = 2*invZ-invZ*Z*invZ;
        end
        Y = 0.5*(Y+invZ);
        Z = 0.5*(Z+invY);
    end
    P_sqrtm_right = Z;
    B = H * P;
    K = B*P_sqrtm_right;
    G = K' / (B * H' + R);
    w_t = 1 ./ (sum(G.' .* K, 1)').^standardization_exponent;
    D = w_t .* P_sqrtm_right;
    % kf_update is the update step of kalman filter
    v = y-H*m;

    S = H*P*H'+R;
    K = (P*H')/S;     % /S is  same as *inv(S) but faster and more accurate

    m = m+K*v;
    P = P-K*S*K';


end
