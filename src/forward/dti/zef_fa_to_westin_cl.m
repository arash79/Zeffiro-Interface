function cl = zef_fa_to_westin_cl(fa)
%ZEF_FA_TO_WESTIN_CL  Uniaxial fractional anisotropy → Westin linear anisotropy.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   For a uniaxial tensor with eigenvalues (1+2α, 1−α, 1−α), Westin
%   C_L = α and
%
%     FA = √3 α / √(1 + 2 α^2)  ⇒  α = FA / √(3 − 2 FA^2).
%
%   FA is clamped to [0, 1]. Using FA itself as α overstates anisotropy
%   (e.g. FA = 0.7 → C_L ≈ 0.49).
%
%   cl = zef_fa_to_westin_cl(fa)
%
%   See also zef_freesurfer_fa_to_conductivity.

fa = min(1, max(0, double(fa)));
cl = fa ./ sqrt(3 - 2 * fa.^2);

end
