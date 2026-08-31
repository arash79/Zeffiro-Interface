function [S_C,orj] = zef_subspace_corr(A,B,chararcter)
%ZEF_SUBSPACE_CORR  Principal angles / correlation between subspaces A and B.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [S_C, orj] = zef_subspace_corr(A, B, chararcter)
%
%   SVD of each matrix (drop zero singular values), C = U_A' U_B, economy
%   SVD of C. S_C is that singular-value vector, or max(S_C) when
%   chararcter is 'max' (third argument is spelled chararcter). Do not
%   call diag() on a vector S — that built a matrix and made max() a
%   row, so RAP-MUSIC kept the first location whenever Φ_s was 1-D.
%
%   See also RAP_MUSIC_iteration.

[U_A,S_A,V_A]=svd(A,'econ');
U_A = U_A(:,abs(diag(S_A))>0);
V_A = V_A(:,abs(diag(S_A))>0);
S_A = S_A(abs(diag(S_A))>0,abs(diag(S_A))>0);
[U_B,S_B,V_B]=svd(B,'econ');
U_B = U_B(:,abs(diag(S_B))>0);
V_B = V_B(:,abs(diag(S_B))>0);
S_B = S_B(abs(diag(S_B))>0,abs(diag(S_B))>0);

C = U_A'*U_B;
[U_C,S_C,V_C] = svd(C,'econ');

U_a = U_A*U_C;
U_b = U_B*V_C;

X = V_A*(S_A\U_C);
Y = V_B*(S_B\V_C);

orj = X(:,1)/norm(X(:,1));
sv = diag(S_C);
if strcmp(chararcter,'max')
    S_C = max(sv);
else
    S_C = sv;
end

end
