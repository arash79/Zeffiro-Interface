function result = run_inverse_job(bundle_path, result_path, opts)
% --- Zeffiro documentation header ---
% utilities.cluster.run_inverse_job — Run inverse job.
%
% Purpose:
%   Run inverse job.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   bundle_path
%   result_path
%   opts
%
% Outputs:
%   result
%
% Calls (project):
%   utilities.cluster.dispatch_inverse
%   utilities.cluster.run_inverse_job
%
% Side effects:
%   - filesystem I/O
%   - parallel/cluster
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[result] = utilities.cluster.run_inverse_job(bundle_path, result_path, opts)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
        error("utilities.cluster:InvalidBundleFile", ...
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
