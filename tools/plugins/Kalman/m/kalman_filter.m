function [P_store,z_inverse] = kalman_filter(m,P,A,Q,L,R, timeSteps ,number_of_frames, smoothing)
% --- Zeffiro documentation header ---
% kalman_filter — Kalman filter.
%
% Purpose:
%   Kalman filter.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   m
%   P
%   A
%   Q
%   L
%   R
%   timeSteps
%   number_of_frames
%   smoothing
%
% Outputs:
%   P_store
%   z_inverse
%
% Calls (project):
%   zef_waitbar
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[P_store, z_inverse]] = kalman_filter(m, P, A, Q, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

P_store = cell(0);
z_inverse = cell(0);
h = zef_waitbar(0,1, 'Filtering');
for f_ind = 1: number_of_frames
    zef_waitbar(f_ind,number_of_frames,h,...
        ['Filtering ' int2str(f_ind) ' of ' int2str(number_of_frames) '.']);
    f = timeSteps{f_ind};
    % Prediction
    [m,P] = kf_predict(m, P, A, Q);
    % Update
    [m, P] = kf_update(m, P, f, L, R);
    if (smoothing == 2)
        P_store{f_ind} = gather(P);
    end
    z_inverse{f_ind} = gather(m);
end
close(h);
end
