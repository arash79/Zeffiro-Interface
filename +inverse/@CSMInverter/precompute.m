function self = precompute(self, L)
% --- Zeffiro documentation header ---
% inverse.CSMInverter.precompute — Precomputes cached operators before the per-frame inversion loop.
%
% Purpose:
%   Precomputes cached operators before the per-frame inversion loop.
%   Folder: Object-oriented inverse solvers (`inverse.*Inverter`) sharing `inverse.CommonInverseParameters`; orchestrated from `src/inverse` and `+utilities/+cluster`.
%
% Inputs:
%   self
%   L
%
% Outputs:
%   self
%
% Calls (project):
%   inverse.precompute
%
% Side effects:
%   - GPU
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[self] = inverse.CSMInverter.precompute(self, L)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
