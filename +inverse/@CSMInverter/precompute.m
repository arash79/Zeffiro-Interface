function self = precompute(self, L)
%PRECOMPUTE Cache frame-invariant matrices for CSM variants.

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
