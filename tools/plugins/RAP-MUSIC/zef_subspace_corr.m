function [S_C,orj] = zef_subspace_corr(A,B,chararcter)
% --- Zeffiro documentation header ---
% zef_subspace_corr — Zef subspace corr.
%
% Purpose:
%   Zef subspace corr.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   A
%   B
%   chararcter
%
% Outputs:
%   S_C
%   orj
%
% Calls (project):
%   zef_subspace_corr
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[S_C, orj]] = zef_subspace_corr(A, B, chararcter)` with project root and `src` on the path.
% --- End Zeffiro documentation header


[U_A,S_A,V_A]=svd(A,'econ');
U_A = U_A(:,abs(diag(S_A))>0);
V_A = V_A(:,abs(diag(S_A))>0);
S_A = S_A(abs(diag(S_A))>0,abs(diag(S_A))>0);
[U_B,S_B,V_B]=svd(B,'econ');
U_B = U_B(:,abs(diag(S_B))>0);
V_B = V_B(:,abs(diag(S_B))>0);
S_B = S_B(abs(diag(S_B))>0,abs(diag(S_B))>0);

C = U_A'*U_B;
[U_C,S_C,V_C] = svd(C);

U_a = U_A*U_C;
U_b = U_B*V_C;

X = V_A*(S_A\U_C);
Y = V_B*(S_B\V_C);

orj = X(:,1)/norm(X(:,1));
S_C = diag(S_C);

if strcmp(chararcter,'max')
    S_C = max(S_C);
end

end
