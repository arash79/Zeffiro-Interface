function self = initialize(self, L, f_data)
% --- Zeffiro documentation header ---
% inverse.ELORETAInverter.initialize — Estimates priors, noise covariance, or regularization from multi-frame data.
%
% Purpose:
%   Estimates priors, noise covariance, or regularization from multi-frame data.
%   Folder: Object-oriented inverse solvers (`inverse.*Inverter`) sharing `inverse.CommonInverseParameters`; orchestrated from `src/inverse` and `+utilities/+cluster`.
%
% Inputs:
%   self
%   L
%   f_data
%
% Outputs:
%   self
%
% Calls (project):
%   inverse.initialize
%
% Side effects:
%   - GPU
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[self] = inverse.ELORETAInverter.initialize(self, L, f_data)` with project root and `src` on the path.
% --- End Zeffiro documentation header

arguments
    self (1,1) inverse.ELORETAInverter
    L (:,:) {mustBeA(L,["double","gpuArray"])}
    f_data (:,:) {mustBeA(f_data,["double","gpuArray"])}
end

self.computing_parameters = true;

noise_p2 = 10^(-self.signal_to_noise_ratio/10);

if isempty(self.noise_cov)
    if size(f_data,2) > 1
        self.noise_cov = cov(f_data');
    else
        self.noise_cov = noise_p2 * mean(f_data.^2) * eye(size(L,1), "like", L);
    end
end

if isempty(self.regularization_parameter)
    self.regularization_parameter = ...
        trace(L*L') / (size(L,1) * 10^(self.signal_to_noise_ratio/10));
end

self.computing_parameters = false;

end
