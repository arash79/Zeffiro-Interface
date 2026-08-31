function x = zef_KDMD(x,K,M,D,use_gpu)
%ZEF_KDMD  Apply (K + D M D) x (NSE implicit viscous/mass block).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Matrix-free product used inside PCG: y = K*x + D*(M*(D*x)). Optional
%   gpuArray promotion when use_gpu is true. Not a DMD time-series method
%   despite the name.
%
%   x = zef_KDMD(x, K, M, D, use_gpu)
%
%   See also zef_nse_iteration, pcg_iteration.

if use_gpu
    x = gpuArray(x);
    K = gpuArray(K);
    M = gpuArray(M);
    D = gpuArray(D);
end

y = D*x;
y = M*y;
y = D*y;
x = K*x + y;

end
