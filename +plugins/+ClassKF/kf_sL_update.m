function [m, P, K, D] = kf_sL_update(m, P, y, H, R)
% --- Zeffiro documentation header ---
% plugins.ClassKF.kf_sL_update — Kf s L update.
%
% Purpose:
%   Kf s L update.
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
%   plugins.ClassKF.kf_sL_update
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[m, P, K]] = plugins.ClassKF.kf_sL_update(m, P, y, H, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

method = '1';  % 1: sqrtm; 2: SVD-based (for singular/near-singular P)
if method == '1'
    P_sqrtm = sqrtm(P);
    B = H * P_sqrtm;
    G = B' / (B * B' + R);
    w_t = 1 ./ sqrt(sum(G.' .* B, 1))';
    D = w_t .* inv(P_sqrtm);
elseif method == '2'
    [Ur,Sr,Vr] = svd(P);
    Sr = diag(Sr);
    RNK = sum(Sr > (length(Sr) * eps(single(Sr(1)))));
    SIR = Vr(:,1:RNK) * diag(1./sqrt(Sr(1:RNK))) * Ur(:,1:RNK)'; % square root
    P_sqrtm = Vr(:,1:RNK) * diag(sqrt(Sr(1:RNK))) * Ur(:,1:RNK)';
    B = H * P_sqrtm;
    G = B' / (B * B' + R);
    w_t = 1 ./ sum(G.' .* B, 1)';
    D = w_t .* SIR;
end

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
