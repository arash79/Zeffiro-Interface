% ZEF_CLUSTER_RECONSTRUCTIONS_FOCAL_EPILEPSY - Cluster inverse results and select by credibility
%
% For each inverse method: finds max-magnitude point, runs GMM clustering on
% the reconstruction, extracts cluster centre. Combines max points and cluster
% centres as reference points, then applies credibility-based clustering
% (zef_find_clusters) to select the most credible subset. Sets J_aux (indices
% of selected methods) for use by zef_final_reconstruction_focal_epilepsy.
%
% Requires: z_inverse_results, z_inverse_info, zef (with source_positions),
% parameters from zef_parameters_focal_epilepsy.
%
% See also: zef_find_clusters, zef_rec_maximizer, zef_cluster_reconstruction

zef.reconstruction = cell(0);

z_max_points = zeros(length(z_inverse_results), 3);
z_cluster_centres = zeros(length(z_inverse_results), 3);
z_max_deviations = zeros(length(z_inverse_results), 1);
z_mean_deviations = zeros(length(z_inverse_results), 1);

% For each inverse method: max point, GMM clustering, cluster centre.
for k = 1 : length(z_inverse_results)

    z_max_points(k, :) = examples.studies.decision_making.zef_rec_maximizer(z_inverse_results{k}, zef.source_positions);

    zef.GMModel.max_n_clusters = max_n_clusters;
    zef.GMModel.frame_number = frame_number;
    zef.GMModel.credibility = cred_val_rec;
    zef.GMModel.n_dynamic_levels = n_dynamic_levels;
    zef.GMModel.reg_param = reg_param_rec;
    zef.GMModel.max_n_iter = max_iter;
    zef.GMModel.tol_val = tol_val_rec;
    zef.reconstruction{1} = z_inverse_results{k};

    [z_cluster_centres_aux, z_dipole_moments_aux, ~, GMModel] = zef_cluster_reconstruction(zef);
    [~, max_ind] = max(sqrt(sum(z_dipole_moments_aux.^2, 2)));
    z_cluster_centres(k, :) = z_cluster_centres_aux(max_ind, :);
    z_max_deviations(k, :) = max(sqrt(eigs(GMModel.Sigma(:, :, max_ind))));
    z_mean_deviations(k, :) = mean(sqrt(eigs(GMModel.Sigma(:, :, max_ind))));

end

% Combine max points and cluster centres; apply credibility-based clustering.
z_ref_points = [z_max_points; z_cluster_centres];
if isequal(supervised_clustering,'on')
    load(credibility_data_file_name)
else
    credibility_data = cred_val_points*ones(size(z_ref_points,1),1);
end

[I_aux,MahalanobisD,GMModel] = zef_find_clusters(size(z_ref_points,1),z_ref_points,reg_param_points,credibility_data,max_iter,tol_val_points);
[~,max_ind] = max(accumarray(I_aux,ones(size(I_aux))));
J_aux = find(I_aux==max_ind);
