function self = precompute(self, L)
%precompute  Cache P = L'/(L*L'+S) and dSPM/sLORETA standardization vector d.
%
%   Zeffiro Interface.
%   Copyright © 2025- Joonas Lahtinen
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from utilities.inverse.run_frame_loop when the inverter has a
%   precompute method. invert reuses precomputed_P and precomputed_d so
%   each frame is a matrix–vector product.
%
%   Only method_type "dSPM", "sLORETA", and "sLORETA 3D" run this body. "SBL"
%   clears the caches and returns. S = (10^(-SNR/20)^2 / theta0) I.
%   dSPM: d_i = 1/sqrt(sum((P S).*P, 2)) i.e. 1/sqrt((P S P')_ii).
%   sLORETA: d = 1./sqrt(sum(P.'.*L,1))' (diagonal of P L).
%   sLORETA 3D: stores P and 3×3 G^{-1/2} pages for interleaved (x,y,z)
%   triplets (d unused). Eigenvalues are floored as in eLORETA.
%
%   Input
%     L  - n_sensors×n_dof lead field after zef_processLeadfields (same
%          matrix invert will see).
%
%   Output
%     self with precomputed_P, precomputed_d set or emptied.

arguments
    self (1,1) inverse.CSMInverter
    L (:,:) {mustBeA(L,["double","gpuArray"])}
end

self.precomputed_P = [];
self.precomputed_d = [];
self.precomputed_Minv = [];
self.precomputed_cache_key = struct([]);

if ~ismember(self.method_type, ["dSPM", "sLORETA", "sLORETA 3D"])
    return;
end

std_lhood = 10^(-self.signal_to_noise_ratio/20);
S_mat = (std_lhood^2/self.theta0) * eye(size(L,1), 'like', L);
P = L'/(L*L' + S_mat);

if self.method_type == "dSPM"
    d = 1./sqrt(sum(((P*S_mat).*P),2));
elseif self.method_type == "sLORETA"
    d = 1./sqrt(sum(P.'.*L,1))';
else
    d = [];
end

self.precomputed_P = P;
self.precomputed_d = d;
self.precomputed_cache_key = self.cacheKey(L);

if self.method_type == "sLORETA 3D" && mod(size(L,2), 3) == 0
    n = size(L, 2) / 3;
    if isa(P, "gpuArray")
        self.precomputed_Minv = zef_sloreta3d_build_minv(gather(P), gather(L), 1:n);
    else
        self.precomputed_Minv = zef_sloreta3d_build_minv(P, L, 1:n);
    end
end

end
