function P_invsqrt = spd_invsqrt_denman_beavers(P)
%SPD_INVSQRT_DENMAN_BEAVERS  Symmetric inverse square root of an SPD matrix.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   P_invsqrt = inverse.kf.spd_invsqrt_denman_beavers(P)
%
%   Computes V diag(1/sqrt(λ)) V' from the symmetric eigendecomposition of
%   (P+P')/2, with non-positive eigenvalues floored to 0 and tiny
%   eigenvalues dropped. The historical N=5/M=1 Schulz-from-I stencil
%   diverged whenever λ(P) left (0, 2) and is not used.
%
%   The function name is kept so kf_sL_update_approx / RTS call sites stay
%   stable. This is inv(sqrtm(P)) for SPD P, not a low-accuracy substitute.
%
%   Used by kf_sL_update_approx and the approximated-sLORETA RTS branch.

    arguments
        P {mustBeA(P, ["double", "single", "gpuArray"])}
    end

    if isempty(P) || size(P, 1) ~= size(P, 2)
        error("kf:BadSpdInvsqrtSize", ...
            "P must be a square matrix; got size %s.", mat2str(size(P)));
    end

    P = (P + P') / 2;
    if isa(P, "gpuArray")
        P = gather(P);
        on_gpu = true;
    else
        on_gpu = false;
    end
    P = double(P);

    [V, d] = eig(P, "vector");
    d = real(d);
    d = max(d, 0);
    s = sqrt(d);
    smax = max(s);
    tol = max(smax, eps) * eps * numel(s);
    sinv = zeros(size(s));
    keep = s > tol;
    sinv(keep) = 1 ./ s(keep);
    P_invsqrt = V * diag(sinv) * V';
    P_invsqrt = (P_invsqrt + P_invsqrt') / 2;

    if on_gpu
        P_invsqrt = gpuArray(P_invsqrt);
    end
end
