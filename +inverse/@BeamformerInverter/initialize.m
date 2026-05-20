function self = initialize(self,L,f_data)
% --- Zeffiro documentation header ---
% inverse.BeamformerInverter.initialize — Estimates priors, noise covariance, or regularization from multi-frame data.
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
%   Programmatic: `[self] = inverse.BeamformerInverter.initialize(self, L, f_data)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    arguments

        self (1,1) inverse.BeamformerInverter

        L (:,:) {mustBeA(L,["double","gpuArray"])}

        f_data (:,:) {mustBeA(f_data,["double","gpuArray"])}

    end
    self.computing_parameters = true;
   % Compute error covariance matrix if it is not given
   if isempty(self.error_cov)
       if size(f_data,2) > 1
           self.error_cov = (f_data-mean(f_data,2))*(f_data-mean(f_data,2))'/size(f_data,2);
       else
           self.error_cov = (f_data-mean(f_data,1))*(f_data-mean(f_data,1))';
       end
   end

end
