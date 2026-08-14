%ZEF_CLUSTER_RECONSTRUCTIONS_FOCAL_EPILEPSY  GMM of max-points and cluster centres.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Needs workspace z_inverse_results, zef.source_positions, and
%   the parameters from zef_parameters_focal_epilepsy. For each method:
%   zef_rec_maximizer, then zef_cluster_reconstruction (GMModel fields on
%   zef). Stacks max points and centres as z_ref_points. If
%   supervised_clustering=='on', load(credibility_data_file_name) into
%   credibility_data; else cred_val_points ones. zef_find_clusters →
%   I_aux, J_aux = indices of the largest cluster (used by process/final).
%
%   See also zef_final_reconstruction_focal_epilepsy, zef_rec_maximizer.

zef.reconstruction = cell(0);

z_max_points = zeros(length(z_inverse_results), 3);
z_cluster_centres = zeros(length(z_inverse_results), 3);
z_max_deviations = zeros(length(z_inverse_results), 1);
z_mean_deviations = zeros(length(z_inverse_results), 1);

% For each inverse method: max point, GMM clustering, cluster centre.
for k = 1 : length(z_inverse_results)

    z_max_points(k, :) = examples.studies.decision_making.helpers.zef_rec_maximizer(z_inverse_results{k}, zef.source_positions);

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
