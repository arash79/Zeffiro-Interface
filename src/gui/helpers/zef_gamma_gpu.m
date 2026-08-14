function [p_val] = zef_gamma_gpu(x, shape,scale)
%ZEF_GAMMA_GPU  Gamma PDF (scale parameterization); gpuArray-compatible.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Elementwise Gamma density
%     p(x) = 1 / (scale^shape * Gamma(shape)) * x^(shape-1) * exp(-x/scale).
%   MATLAB's gamma and array ops accept gpuArray, which is why the name
%   has _gpu; there is no separate GPU kernel.
%
%   Callers: zef_find_g_hyperprior (tail search for inverse Gamma
%   hyperpriors); zef_plot_hyperprior when zef.inv_hyperprior==2;
%   zef_inverse_gamma_gpu as Gamma(1/x; shape, 1/scale) / x^2.
%
%   p_val = zef_gamma_gpu(x, shape, scale)
%
%   Inputs
%     x, shape, scale - real arrays, broadcast as MATLAB allows.
%
%   Output
%     p_val - same size as the broadcast of x.
%
%   See also zef_inverse_gamma_gpu, zef_find_g_hyperprior, zef_plot_hyperprior.
p_val = (1./(scale.^shape.*gamma(shape))).*x.^(shape-1).*exp(-x./scale);

end
