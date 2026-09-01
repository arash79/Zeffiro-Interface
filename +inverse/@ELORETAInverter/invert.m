function [z_vec, self] = invert(self, f, L, procFile, source_direction_mode, source_positions, opts)
%invert  Apply cached eLORETA operator: z = T*f for one measurement frame.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from utilities.inverse.run_frame_loop. There is no default-profile
%   Inverse-tools button that constructs ELORETAInverter; use
%   zef_inverse_run(zef, "eloreta", "execution", "local") or this class
%   directly. If precomputed_inverse_operator is empty, calls precompute
%   (fixed-point W^{-1}, then T = W^{-1} L' M^{-1}).
%
%   Inputs
%     f     - n_sensors×1 filtered frame.
%     L     - processed lead field (needed only when T is not yet cached).
%     procFile - passed through to precompute (s_ind_4 = fixed-orientation
%             sources under direction mode 2). Unused once T exists.
%     source_direction_mode, source_positions - unused here.
%     opts.use_gpu - upload T and f, then gather z.
%     opts.normalize_data - unused here.
%
%   Outputs
%     z_vec - n_dof×1 eLORETA estimate T*f.
%     self  - T cached on precomputed_inverse_operator.

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
    cleanup_fn = @zef_close_waitbar;
    cleanup_obj = onCleanup(@() cleanup_fn(h)); %#ok<NASGU>
end

% T is only valid for the lead field and settings it was built from, so a
% settings change between precompute and invert must rebuild it rather than
% silently reuse the old operator.
if ~isempty(self.precomputed_inverse_operator) ...
        && ~isequaln(self.precomputed_cache_key, self.cacheKey(L, procFile))
    self.precomputed_inverse_operator = [];
    self.precomputed_cache_key = struct([]);
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
