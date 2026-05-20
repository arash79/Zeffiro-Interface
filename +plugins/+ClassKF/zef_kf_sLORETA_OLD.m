function [P, L, Q] = zef_kf_sLORETA_OLD(L, Q, std_lhood, theta0)
%ZEF_KF_SLORETA_OLD Legacy sLORETA-based prior initialization for Kalman filter.
%
%   [P, L, Q] = ZEF_KF_SLORETA_OLD(L, Q, STD_LHOOD, THETA0) computes initial
%   prior covariance P and modified lead field L for a sLORETA-inspired
%   Kalman filter setup. Uses diagonal resolution weighting.
%
%   Inputs:
%     L        - Lead field matrix
%     Q        - Process noise covariance
%     STD_LHOOD- Measurement noise standard deviation
%     THETA0   - Prior variance scaling
%
%   Outputs:
%     P - Initial prior covariance (diagonal)
%     L - Modified lead field (scaled by chol(D2))
%     Q - Modified process noise
%
%   Note: Legacy function; consider using zef_KF with standard initialization.
D2 = inv(sparse(diag(diag(L' / (L * L' + std_lhood^2 / theta0 * eye(size(L,1))) * L))));
    P = theta0 * D2;
    L = L / chol(D2);
    Q = D2*Q;
end

