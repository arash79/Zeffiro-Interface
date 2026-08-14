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
%   Only method_type "dSPM" and "sLORETA" run this body. "sLORETA 3D" and
%   "SBL" clear the caches and return. S = (10^(-SNR/20)^2 / theta0) I.
%   dSPM: d_i = 1/sqrt(sum((P S).*P, 2)) i.e. 1/sqrt((P S P')_ii).
%   sLORETA: d = 1./sqrt(sum(P.'.*L,1))' (diagonal of P L).
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

if ~ismember(self.method_type, ["dSPM", "sLORETA"])
    return;
end

std_lhood = 10^(-self.signal_to_noise_ratio/20);
S_mat = (std_lhood^2/self.theta0) * eye(size(L,1), 'like', L);
P = L'/(L*L' + S_mat);

if self.method_type == "dSPM"
    d = 1./sqrt(sum(((P*S_mat).*P),2));
else
    d = 1./sqrt(sum(P.'.*L,1))';
end

self.precomputed_P = P;
self.precomputed_d = d;

end
