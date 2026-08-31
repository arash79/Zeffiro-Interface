function n = zef_gpu_count
%ZEF_GPU_COUNT  Number of GPU devices, or 0 if PCT/GPU is unavailable.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   gpuDeviceCount belongs to Parallel Computing Toolbox. Calling it
%   without that toolbox errors and used to abort zeffiro_interface.
%   Missing toolbox, missing license, or a failed device query all
%   return 0 so CPU-only sessions can start.
%
%   See also gpuDeviceCount, zef_start.

n = 0;
try
    if exist('gpuDeviceCount', 'file') ~= 2
        return
    end
    if ~license('test', 'distrib_computing_toolbox')
        return
    end
    n = gpuDeviceCount;
catch
    n = 0;
end

end
