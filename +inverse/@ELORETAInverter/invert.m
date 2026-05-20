function [z_vec, self] = invert(self, f, L, procFile, source_direction_mode, source_positions, opts)
% --- Zeffiro documentation header ---
% inverse.ELORETAInverter.invert — Runs one inverse reconstruction step for a single measurement frame.
%
% Purpose:
%   Runs one inverse reconstruction step for a single measurement frame.
%   Folder: Object-oriented inverse solvers (`inverse.*Inverter`) sharing `inverse.CommonInverseParameters`; orchestrated from `src/inverse` and `+utilities/+cluster`.
%
% Inputs:
%   self
%   f
%   L
%   procFile
%   source_direction_mode
%   source_positions
%   opts
%
% Outputs:
%   z_vec
%   self
%
% Calls (project):
%   inverse.invert
%   zef_waitbar
%
% Side effects:
%   - GPU
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[z_vec, self]] = inverse.ELORETAInverter.invert(self, f, L, procFile, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

arguments
    self (1,1) inverse.ELORETAInverter
    f (:,1) {mustBeA(f,["double","gpuArray"])}
    L (:,:) {mustBeA(L,["double","gpuArray"])}
    procFile (1,1) struct
    source_direction_mode
    source_positions
    opts.use_gpu (1,1) logical = false
    opts.normalize_data (1,1) double = 1
end

self.computing_parameters = false;

if self.number_of_frames <= 1
    h = zef_waitbar(0, 'eLORETA reconstruction.');
    cleanup_fn = @(wb) close(wb);
    cleanup_obj = onCleanup(@() cleanup_fn(h)); %#ok<NASGU>
end

if isempty(self.precomputed_inverse_operator)
    self = self.precompute(L, procFile);
end

T = self.precomputed_inverse_operator;
if opts.use_gpu && gpuDeviceCount > 0
    if ~isa(T, "gpuArray")
        T = gpuArray(T);
    end
    if ~isa(f, "gpuArray")
        f = gpuArray(f);
    end
end

z_vec = T * f;

if opts.use_gpu && gpuDeviceCount > 0
    z_vec = gather(z_vec);
end

end
