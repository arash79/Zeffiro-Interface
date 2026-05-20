% --- Zeffiro documentation header ---
% examples.studies.decision_making.helpers.z_inverse_info = [z_inverse_info repmat({'Maximum point'}, size(z_inverse_info, 1), 1); z_inverse_info repmat({'Cluster centre'}, size(z_inverse_info, 1), 1)]; — Example or study script demonstrating z_inverse_info = [z_inverse_info repmat({'Maximum point'}, size(z_inverse_info, 1), 1); z_inverse_info repmat({'Cluster centre'}, size(z_inverse_info, 1), 1)];.
%
% Purpose:
%   Example or study script demonstrating z_inverse_info = [z_inverse_info repmat({'Maximum point'}, size(z_inverse_info, 1), 1); z_inverse_info repmat({'Cluster centre'}, size(z_inverse_info, 1), 1)];.
%   Folder: Runnable examples and study scripts that exercise meshing, forward lead fields, inverse solvers, importing, and published workflows.
%
% Zef fields (observed):
%   zef.GMModel (read)
%   zef.reconstruction (read)
%   zef.source_positions (read)
%
% Calls (project):
%   zef_cluster_reconstruction
%   zef_rec_maximizer
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `examples.studies.decision_making.helpers.z_inverse_info = [z_inverse_info repmat({'Maximum point'}, size(z_inverse_info, 1), 1); z_inverse_info repmat({'Cluster centre'}, size(z_inverse_info, 1), 1)];` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

z_inverse_info = [z_inverse_info repmat({'Maximum point'}, size(z_inverse_info, 1), 1); z_inverse_info repmat({'Cluster centre'}, size(z_inverse_info, 1), 1)];
z_inverse_results = [z_inverse_results z_inverse_results];
z_mean_deviations = [zeros(size(z_max_deviations)); z_mean_deviations];
z_max_deviations = [zeros(size(z_max_deviations)); z_max_deviations];

z_cluster_mean = GMModel.mu(max_ind,:);
z_cluster_deviation = max(sqrt(eigs(GMModel.Sigma(:,:,max_ind))));
z_inverse_results = z_inverse_results(J_aux);
z_inverse_info = z_inverse_info(J_aux,:);
z_ref_points_full = z_ref_points;
z_ref_points = z_ref_points(J_aux,:);
z_max_deviations = z_max_deviations(J_aux,:);
z_mean_deviations = z_mean_deviations(J_aux,:);

z_final = zeros(length(z_inverse_results{1}),1);

for k = 1 : length(z_inverse_results)

    z_final = z_final + z_inverse_results{k};

end

z_final_max_point = examples.studies.decision_making.helpers.zef_rec_maximizer(z_final,zef.source_positions);

zef.GMModel.max_n_clusters = 100;
zef.GMModel.frame_number = 1;
zef.GMModel.credibility = 0.95;
zef.GMModel.n_dynamic_levels = 4;
zef.GMModel.reg_param = 1E-5;
zef.GMModel.max_n_iter = 1000;
zef.GMModel.tol_val_rec = 1E-3;
zef.reconstruction{1} = z_inverse_results{k};

[z_cluster_centres_aux,z_dipole_moments_aux,~,GMModel] = zef_cluster_reconstruction(zef);
[~, max_ind] = max(sqrt(sum(z_dipole_moments_aux.^2,2)));
%  z_final_cluster_centre = z_cluster_centres_aux(max_ind,:);
z_final_max_deviation = max(sqrt(eigs(GMModel.Sigma(:,:,max_ind))));
z_final_mean_deviation = (mean(sqrt(eigs(GMModel.Sigma(:,:,max_ind)))));
%dist_vec_final = sqrt(sum((z_final_cluster_centre - z_final_max_point).^2,2));
