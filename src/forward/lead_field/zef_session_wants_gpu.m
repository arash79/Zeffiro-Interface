function tf = zef_session_wants_gpu(zef)
%ZEF_SESSION_WANTS_GPU  True when the session asked for GPU and a device is listed.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Reads zef.use_gpu and zef.gpu_count on the argument, not evalin('base').
%   FEM kernels that used evalin('base','zef.gpu_count') failed in tests,
%   cluster workers, and any call that did not assign zef into base.
%
%   tf = zef_session_wants_gpu(zef)
%
%   See also zef_lead_field_meg_fem, zef_transfer_matrix.

    tf = false;
    if nargin < 1 || isempty(zef) || ~isstruct(zef)
        return
    end
    if ~isfield(zef, 'use_gpu') || ~isequal(zef.use_gpu, 1)
        return
    end
    if isfield(zef, 'gpu_count')
        tf = zef.gpu_count > 0;
        return
    end
    try
        tf = gpuDeviceCount > 0;
    catch
        tf = false;
    end
end
