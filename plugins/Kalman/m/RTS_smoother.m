function [P_s_store, m_s_store, G_store] = RTS_smoother(P_store, z_inverse, A, Q, number_of_frames)
%RTS_SMOOTHER  Rauch–Tung–Striebel smoother on stored P and filtered means.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [P_s_store, m_s_store, G_store] = RTS_smoother(P_store, z_inverse, A, Q, number_of_frames)
%
%   zef_KF when zef.kf_smoothing == 2 (dropdown RTS). Walks frames backward
%   with A (usually I) and Q. zef_KF then replaces z_inverse with m_s_store.
%
%   Inputs
%     P_store           - cell of filtered P (from kalman_filter when smoothing==2)
%     z_inverse         - cell of filtered means
%     A                 - transition
%     Q                 - process noise
%     number_of_frames  - length of the cells
%
%   Outputs
%     P_s_store  - smoothed covariances
%     m_s_store  - smoothed means (used as reconstruction)
%     G_store    - RTS gains
%
%   See also zef_KF, Block_RTS_smoother, kalman_filter.
%

P_s_store = cell(0);
m_s_store = cell(0);
G_store = cell(0);
h = zef_waitbar(0,'Smoothing');
for f_ind = number_of_frames:-1:1
    zef_waitbar(1 - f_ind/number_of_frames,h, ['Smoothing ' int2str(number_of_frames -f_ind) ' of ' int2str(number_of_frames) '.']);

    P = P_store{f_ind};
    m = z_inverse{f_ind};
    % if A is Identity
    if inverse.kf.is_identity_transition(A)
        P_ = P + Q;
        m_ = m;
        G =  P / P_;
    else
        P_ = A * P * A' + Q;
        m_ = A * m;
        G =  (P * A') / P_;
    end
    if f_ind == number_of_frames
        m_s = m;
        P_s = P;
    else
        m_s = m + G * (m_s - m_);
        P_s = P + G * (P_s - P_) * G';
    end
    P_s_store{f_ind} = P_s;
    G_store{f_ind} = G;
    m_s_store{f_ind} = m_s;
end

zef_close_waitbar(h);
end
