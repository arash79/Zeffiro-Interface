function submissions = submit_inverse_jobs(cluster_profile, bundles, opts)
%SUBMIT_INVERSE_JOBS Submit inverse bundles as cluster batch jobs.

arguments
    cluster_profile (1,1) parallel.Cluster
    bundles {mustBeA(bundles,["cell","struct"])}
    opts.WorkDir (1,1) string = string(pwd)
    opts.BundleDir (1,1) string = fullfile(string(pwd), "cluster_bundles")
    opts.ResultDir (1,1) string = fullfile(string(pwd), "cluster_results")
    opts.AutoAddClientPath (1,1) logical = false
    opts.CaptureDiary (1,1) logical = true
    opts.Pool (1,1) double {mustBeInteger,mustBeNonnegative} = 0
end

if isstruct(bundles)
    bundles = num2cell(bundles);
end

if ~isfolder(opts.BundleDir)
    mkdir(opts.BundleDir);
end
if ~isfolder(opts.ResultDir)
    mkdir(opts.ResultDir);
end

submissions = repmat(struct( ...
    "job", [], ...
    "bundle_path", "", ...
    "result_path", "" ...
), numel(bundles), 1);

for idx = 1:numel(bundles)
    bundle = bundles{idx};
    stamp = char(string(datetime("now","Format","yyyyMMdd_HHmmss_SSS")));
    bundle_path = fullfile(opts.BundleDir, sprintf("inverse_bundle_%03d_%s.mat", idx, stamp));
    result_path = fullfile(opts.ResultDir, sprintf("inverse_result_%03d_%s.mat", idx, stamp));
    save(bundle_path, "bundle", "-v7.3");

    job = batch( ...
        cluster_profile, ...
        @utilities.cluster.run_inverse_job, ...
        1, ...
        {bundle_path, result_path}, ...
        'CurrentFolder', char(opts.WorkDir), ...
        'AutoAddClientPath', opts.AutoAddClientPath, ...
        'CaptureDiary', opts.CaptureDiary, ...
        'Pool', opts.Pool ...
    );

    submissions(idx).job = job;
    submissions(idx).bundle_path = string(bundle_path);
    submissions(idx).result_path = string(result_path);
end

end
