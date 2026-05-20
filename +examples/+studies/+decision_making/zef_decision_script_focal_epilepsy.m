% ZEF_DECISION_SCRIPT_FOCAL_EPILEPSY - Main workflow for focal epilepsy source localization
%
% Assumes zef is loaded with a DataBank project containing reconstructions.
% Workflow:
%   1. Load parameters
%   2. Retrieve inverse results from DataBank
%   3. Cluster reconstructions (GMM + credibility-based selection)
%   4. Compute final reconstruction (weighted average of selected methods)
%   5. Display results (table + plots)
%
% Prerequisites: Run zef_find_reconstructions_focal_epilepsy first to populate
% the DataBank with inverse results.
%
% See also: zef_find_reconstructions_focal_epilepsy, zef_create_training_data_focal_epilepsy

examples.studies.decision_making.zef_parameters_focal_epilepsy;
[z_inverse_results, z_inverse_info] = zef_dataBank_get_reconstructions(zef, frame_number);
examples.studies.decision_making.zef_cluster_reconstructions_focal_epilepsy;
examples.studies.decision_making.zef_final_reconstruction_focal_epilepsy;
examples.studies.decision_making.zef_show_results_focal_epilepsy;
