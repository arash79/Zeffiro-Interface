function [submissions, bundles] = parameter_sweep(zef, cluster_profile, sweep, opts)
%PARAMETER_SWEEP Submit one inverse job per parameter combination.

arguments
    zef (1,1) struct
    cluster_profile (1,1) parallel.Cluster
    sweep (1,1) struct
    opts.MethodId (1,1) string = "kalman"
    opts.WorkDir (1,1) string = string(pwd)
    opts.BundleDir (1,1) string = fullfile(string(pwd), "cluster_bundles")
    opts.ResultDir (1,1) string = fullfile(string(pwd), "cluster_results")
end

noise_level_vec = i_get_sweep(sweep, "noise_level_vec", 30);
evolution_prior_vec = i_get_sweep(sweep, "evolution_prior_vec", 20);
pm_snr_vec = i_get_sweep(sweep, "pm_snr_vec", 0);

bundles = {};
for i_ind = 1:length(noise_level_vec)
    for j_ind = 1:length(evolution_prior_vec)
        for k_ind = 1:length(pm_snr_vec)
            params = struct( ...
                "noise_level", noise_level_vec(i_ind), ...
                "inv_evolution_prior", evolution_prior_vec(j_ind), ...
                "pm_snr", pm_snr_vec(k_ind) ...
            );
            bundles{end+1} = zef_inverse_extract_bundle( ... %#ok<AGROW>
                zef, ...
                opts.MethodId, ...
                "MethodParams", params ...
            );
        end
    end
end

submissions = utilities.cluster.submit_inverse_jobs( ...
    cluster_profile, ...
    bundles, ...
    "WorkDir", opts.WorkDir, ...
    "BundleDir", opts.BundleDir, ...
    "ResultDir", opts.ResultDir ...
);

end

function val = i_get_sweep(sweep, name, default_val)
if isfield(sweep, name)
    val = sweep.(name);
else
    val = default_val;
end
end
