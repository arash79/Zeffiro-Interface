function [filling_vec] = zef_wireframe_filling_vec(eps_vec_1, eps_vec_2)
%ZEF_WIREFRAME_FILLING_VEC  Maxwell-Garnett filling fraction from two permittivities.
%
%   Copyright © 2019- Sampsa Pursiainen, Liisa-Ida Sorsa, Christelle Eyraud, Jean-Michel Geffrin.
%   GPU-ToRRe-3D wireframe modeling package.
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   filling_vec = zef_wireframe_filling_vec(eps_vec_1, eps_vec_2)
%
%   Real parts only. Called from wireframe generation. No zef I/O.
%
%   See also zef_wireframe_permittivity_vec, wireframe.

filling_vec = - (real(eps_vec_2) - real(eps_vec_1).*(real(eps_vec_2) + 2) + 2)./(2.*real(eps_vec_2) + real(eps_vec_1).*(real(eps_vec_2) - 1) - 2);

end
