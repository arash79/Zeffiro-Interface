function [P_s_store, m_s_store, G_store] = sample_RTS_smoother(P_store, D_store, z_inverse, A, number_of_frames, filter_type)
% --- Zeffiro documentation header ---
% sample_RTS_smoother — Sample RTS smoother.
%
% Purpose:
%   Sample RTS smoother.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   P_store
%   D_store
%   z_inverse
%   A
%   number_of_frames
%   filter_type
%
% Outputs:
%   P_s_store
%   m_s_store
%   G_store
%
% Calls (project):
%   zef_waitbar
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[P_s_store, m_s_store, G_store]] = sample_RTS_smoother(P_store, D_store, z_inverse, A, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

P_s_store = cell(0);
m_s_store = cell(0);
G_store = cell(0);

z_inverse = cell2mat(z_inverse);
if (isdiag(A) && all(diag(A) - 1) < eps)
    Q = cov((z_inverse(:,2:number_of_frames)-z_inverse(:,1:number_of_frames-1))');
else
    Q = cov((z_inverse(:,2:number_of_frames)-A* z_inverse(:,1:number_of_frames-1))');
end
h = zef_waitbar(0,'Smoothing');
for f_ind = number_of_frames:-1:1
    zef_waitbar(1 - f_ind/number_of_frames,h, ['Smoothing (sample-based)' int2str(number_of_frames -f_ind) ' of ' int2str(number_of_frames) '.']);

    if filter_type == 1
        P = P_store{f_ind};
    else
        P = D_store{f_ind}*P_store{f_ind}*D_store{f_ind}';
    end
    m = z_inverse(:,f_ind);
    % if A is Identity
    if (isdiag(A) && all(diag(A) - 1) < eps)
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
    %P_s_store{f_ind} = P_s;
    %G_store{f_ind} = G;
    m_s_store{f_ind} = m_s;
end

close(h);
end
