function [P_s_store, m_s_store, G_store] = Block_RTS_smoother(P_store, z_inverse, A, Q, number_of_frames, dim,sL)
%BLOCK_RTS_SMOOTHER  RTS on a 2- or 3-block (position / velocity / acceleration) state.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [P_s_store, m_s_store, G_store] = Block_RTS_smoother(P_store, z_inverse, A, Q, number_of_frames, dim, sL)
%
%   zef_KF when kf_smoothing is 3 (2Block RTS, dim=2) or 4 (3Block RTS,
%   dim=3). Rebuilds the same A/Q blocks as double_kf_sL / triple_kf_sL.
%   m_s_store is I1*m_s (position / selected block), not the full state.
%
%   See also RTS_smoother, double_kf_sL, triple_kf_sL.
%

P_s_store = cell(0);
m_s_store = cell(0);
G_store = cell(0);
h = zef_waitbar(0,1,'Smoothing');

if sL>=dim
    I1=eye(size(A,1),size(A,1)*dim);
else
    I1=eye(size(A,1)*sL,size(A,1)*dim);
end
zero_m=zeros(size(A,1));

if dim==2
    Q=cell2mat({zero_m,zero_m;zero_m,number_of_frames*Q});
    A=cell2mat({A,(1/number_of_frames)*A;zero_m,A});
elseif dim==3
    Q=cell2mat({zero_m,zero_m,zero_m;zero_m,zero_m,zero_m;zero_m,zero_m,(1/((1/2)*((1/number_of_frames)^2)))*Q});
    A=cell2mat({A,(1/number_of_frames)*A,(1/2)*((1/number_of_frames)^2)*A;zero_m,A,(1/number_of_frames)*A;zero_m,zero_m,A});
end

for f_ind = number_of_frames:-1:1
    zef_waitbar(1 - f_ind,number_of_frames,h, ['Smoothing ' int2str(number_of_frames -f_ind) ' of ' int2str(number_of_frames) '.']);

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
    m_s_store{f_ind} = I1*m_s;
end

zef_close_waitbar(h);
end
