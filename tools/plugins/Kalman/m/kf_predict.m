function [m, P] = kf_predict(m,P,A,Q)
%KF_PREDICT  Kalman predict step m := A m, P := A P A' + Q.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [m, P] = kf_predict(m, P, A, Q)
%
%   Used by kalman_filter, kalman_filter_sLORETA, double_kf_sL, and
%   triple_kf_sL (StartButton → zef_KF). No zef fields.
%
%   Inputs
%     m - current mean
%     P - current covariance
%     A - transition (identity in zef_KF)
%     Q - process noise
%
%   Outputs
%     m - predicted mean
%     P - predicted covariance
%
%   See also kf_update, kalman_filter.
%

    % Identity shortcut as written: all(diag(A)-1) < eps (not all((diag(A)-1)<eps)).
    if (isdiag(A) && all(diag(A) - 1) < eps)
        P = P + Q;
    else
        m = A * m;
        P = A * P * A' + Q;
    end
end
