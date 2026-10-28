function runtime = zef_meshing_runtime(zef)
%ZEF_MESHING_RUNTIME  Session fields read by the solid-angle inside tests.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   runtime = zef_meshing_runtime(zef)
%
%   Copies meshing_accuracy, use_gpu, gpu_num, gpu_count, and
%   parallel_vectors. meshing_threshold defaults to 0.5 when the field is
%   absent. parallel_processes is copied only when the field exists; the
%   CPU inside-test is the only reader.
%
%   An empty zef reads the base-workspace session. The inside tests use
%   this struct instead of eval / evalin on individual fields.
%
%   See also zef_point_in_compartment, zef_tetra_in_compartment.

if nargin < 1 || isempty(zef)
    zef = evalin('base', 'zef');
end

if isfield(zef, 'meshing_threshold')
    runtime.meshing_threshold = zef.meshing_threshold;
else
    runtime.meshing_threshold = 0.5;
end
runtime.meshing_accuracy = zef.meshing_accuracy;
runtime.use_gpu = zef.use_gpu;
runtime.gpu_num = zef.gpu_num;
runtime.gpu_count = zef.gpu_count;
runtime.parallel_vectors = zef.parallel_vectors;
if isfield(zef, 'parallel_processes')
    runtime.parallel_processes = zef.parallel_processes;
end

end
