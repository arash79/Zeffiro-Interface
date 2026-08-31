function p_vec = zef_wireframe_permittivity_vec(f_vec,p_val)
%ZEF_WIREFRAME_PERMITTIVITY_VEC  Effective permittivity from filling fraction p_val.
%
%   Copyright © 2019- Sampsa Pursiainen, Liisa-Ida Sorsa, Christelle Eyraud, Jean-Michel Geffrin.
%   GPU-ToRRe-3D wireframe modeling package.
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   p_vec = zef_wireframe_permittivity_vec(f_vec, p_val)
%
%   Inverse Maxwell-Garnett mixing. No zef I/O.
%
%   See also zef_wireframe_filling_vec.

p_vec = (2.*f_vec.*(p_val - 1) + p_val + 2)./(2 + p_val - f_vec.*(p_val - 1));

end
