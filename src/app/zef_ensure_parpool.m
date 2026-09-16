function started = zef_ensure_parpool(n_workers)
%ZEF_ENSURE_PARPOOL  Size a local parpool when Parallel Computing Toolbox is present.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   started = zef_ensure_parpool(n_workers)
%
%   If Parallel Computing Toolbox is installed and licensed, create a local
%   pool with n_workers workers, or replace an existing pool whose
%   NumWorkers differs. Without the toolbox, do nothing: later parfor loops
%   run sequentially. Never errors on a missing toolbox, missing license,
%   or a failed pool start; started is false in those cases.
%
%   Callers: CPU meshing (zef_create_fem_mesh), EEG/TES transfer PCG
%   (zef_transfer_matrix), MEG/EIT FEM PCG, and wave Born drivers.
%
%   See also zef_gpu_count, parpool, gcp.

started = false;
if nargin < 1 || isempty(n_workers)
    n_workers = 1;
end
n_workers = double(n_workers(1));
if ~isfinite(n_workers) || n_workers < 1
    n_workers = 1;
end
n_workers = max(1, round(n_workers));

try
    if exist('parpool', 'file') ~= 2
        return
    end
    if ~license('test', 'Distrib_Computing_Toolbox')
        return
    end
    if isempty(ver('parallel'))
        return
    end
    pool = gcp('nocreate');
    if isempty(pool)
        parpool(n_workers);
    elseif ~isequal(pool.NumWorkers, n_workers)
        delete(pool);
        parpool(n_workers);
    end
    started = ~isempty(gcp('nocreate'));
catch
    started = false;
end

end
