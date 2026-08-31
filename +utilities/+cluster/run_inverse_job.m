function result = run_inverse_job(bundle_path, result_path, opts)
%RUN_INVERSE_JOB  Cluster worker entry: load bundle, invert, save result MAT-file.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   result = run_inverse_job(bundle_path, result_path, opts)
%
%   Loads variable bundle from bundle_path, calls dispatch_inverse, and writes
%   result to result_path (-v7.3). result includes success, error, executionTime,
%   maxNumCompThreads, method_id, reconstruction, reconstruction_information,
%   and z_inverse. On failure, saves the partial result then rethrows.
%
%   opts.EnableProfiler (default false) wraps dispatch in profile on/off and
%   stores profilerInfo in result when enabled. Intended as the batch() target
%   for submit_inverse_jobs.

arguments
    bundle_path (1,1) string {mustBeFile}
    result_path (1,1) string {mustBeNonempty}
    opts.EnableProfiler (1,1) logical = false
end

result = struct( ...
    "success", false, ...
    "error", "", ...
    "executionTime", [], ...
    "maxNumCompThreads", maxNumCompThreads(), ...
    "method_id", "", ...
    "reconstruction", [], ...
    "reconstruction_information", struct, ...
    "z_inverse", [] ...
);

try
    if opts.EnableProfiler
        profile on;
    end

    loaded = load(bundle_path);
    if ~isfield(loaded, "bundle")
        error("utilities:cluster:InvalidBundleFile", ...
            "Bundle file '%s' does not contain variable 'bundle'.", bundle_path);
    end

    tic;
    dispatch_result = utilities.cluster.dispatch_inverse(loaded.bundle);
    result.executionTime = toc;

    result.success = true;
    result.method_id = dispatch_result.method_id;
    result.reconstruction = dispatch_result.reconstruction;
    result.reconstruction_information = dispatch_result.reconstruction_information;
    result.z_inverse = dispatch_result.z_inverse;

    if opts.EnableProfiler
        profile off;
        result.profilerInfo = profile('info');
    end

    save(result_path, "result", "-v7.3");
catch exception
    result.success = false;
    result.error = getReport(exception, "extended", "hyperlinks", "off");
    if isempty(result.executionTime)
        result.executionTime = NaN;
    end
    save(result_path, "result", "-v7.3");
    rethrow(exception);
end

end
