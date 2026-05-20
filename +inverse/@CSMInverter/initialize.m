%% Copyright © 2025- Joonas Lahtinen
function self = initialize(self,L,f_data)
% --- Zeffiro documentation header ---
% inverse.CSMInverter.initialize — Estimates priors, noise covariance, or regularization from multi-frame data.
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
%   Programmatic: `[self] = inverse.CSMInverter.initialize(self, L, f_data)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    arguments

        self (1,1) inverse.CSMInverter

        L (:,:) {mustBeA(L,["double","gpuArray"])}

        f_data (:,:) {mustBeA(f_data,["double","gpuArray"])}

    end

    noise_p2 = 10^(-self.signal_to_noise_ratio/10);
    self.theta0 = gather((1-noise_p2)*sum(f_data.^2,'all')/sum(L.^2,'all'));
end
