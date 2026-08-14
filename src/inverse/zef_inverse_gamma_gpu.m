function [p_val] = zef_inverse_gamma_gpu(x, shape,scale)
%ZEF_INVERSE_GAMMA_GPU  Inverse-gamma PDF evaluated on GPU via zef_gamma_gpu.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Computes the inverse-gamma density at x using the gamma function identity
%   IG(x; shape, scale) = Gamma(1/x; shape, 1/scale) / x^2. All arguments are
%   forwarded to zef_gamma_gpu on the reciprocal scale.
%
%   p_val = zef_inverse_gamma_gpu(x, shape, scale)
%
%   Inputs
%     x, shape, scale - same types/shapes accepted by zef_gamma_gpu (typically
%                       gpuArray-compatible numerics).
%
%   Output
%     p_val - inverse-gamma PDF values, same size as x.
%
%   See also zef_gamma_gpu.


p_val = zef_gamma_gpu(1./x,shape,1./scale)./(x.^2);

end
