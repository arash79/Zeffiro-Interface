function [m, P] = kf_predict(m,P,A,Q)
% --- Zeffiro documentation header ---
% kf_predict — Kf predict.
%
% Purpose:
%   Kf predict.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   m
%   P
%   A
%   Q
%
% Outputs:
%   m
%   P
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[m, P]] = kf_predict(m, P, A, Q)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    if (isdiag(A) && all(diag(A) - 1) < eps)
        P = P + Q;
    else
        % Basic kalman prediction steps
        m = A * m;
        P = A * P * A' + Q;
    end
end
